import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/tasks/data/task_local_datasource.dart';
import '../../features/tasks/data/task_remote_datasource.dart';
import 'conflict_resolver.dart';
import 'sync_queue_manager.dart';

class SyncProgress {
  final int totalItems;
  final int completedItems;
  final String currentItemDescription;
  final bool isSyncing;

  SyncProgress({
    required this.totalItems,
    required this.completedItems,
    required this.currentItemDescription,
    required this.isSyncing,
  });

  double get progress => totalItems == 0 ? 0 : completedItems / totalItems;
}

class SyncService {
  final SyncQueueManager queueManager;
  final TaskRemoteDataSource remote;
  final TaskLocalDataSource local;
  final ConflictResolver conflictResolver;

  bool _isSyncing = false;
  final _progressController = StreamController<SyncProgress>.broadcast();

  Stream<SyncProgress> get progressStream => _progressController.stream;

  SyncService({
    required this.queueManager,
    required this.remote,
    required this.local,
    required this.conflictResolver,
  });

  /// Triggered whenever a user makes a change or background worker wakes up
  void triggerImmediateSync() {
    if (_isSyncing) return;
    _runSyncRoutine();
  }

  Future<void> _runSyncRoutine() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queueItems = await queueManager.getPendingQueue();
      final total = queueItems.length;
      int completed = 0;

      if (total == 0) {
        _progressController.add(
          SyncProgress(
            totalItems: 0,
            completedItems: 0,
            currentItemDescription: 'Up to date',
            isSyncing: false,
          ),
        );
        return;
      }

      for (final item in queueItems) {
        _progressController.add(
          SyncProgress(
            totalItems: total,
            completedItems: completed,
            currentItemDescription:
                'Processing ${item.entityType} ${item.entityId}...',
            isSyncing: true,
          ),
        );

        await queueManager.markQueueSyncing(item.id);

        try {
          if (item.entityType == 'task') {
            if (item.action == 'update') {
              await remote.syncTaskUpdateToServer(item.payload);
            } else if (item.action == 'create') {
              await remote.syncTaskCreateToServer(item.payload);
            }

            final serverData = await remote.fetchLatestServerTaskData(
              item.entityId,
            );

            final bool hasConflict = await conflictResolver
                .detectAndHandleConflict(
                  item.entityId,
                  jsonDecode(item.payload),
                  serverData,
                );

            if (!hasConflict) {
              await queueManager.markQueueCompleted(item.id);
              await local.markTaskSynced(item.entityId);
            } else {
              await queueManager.markQueueFailed(item.id, item.retryCount);
            }
          }
          completed++;
        } catch (e) {
          debugPrint('Sync failed for item ${item.id}: $e');
          await queueManager.markQueueFailed(item.id, item.retryCount);
        }
      }

      _progressController.add(
        SyncProgress(
          totalItems: total,
          completedItems: completed,
          currentItemDescription: 'Sync complete',
          isSyncing: false,
        ),
      );
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _progressController.close();
  }
}
