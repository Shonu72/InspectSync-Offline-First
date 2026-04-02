import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../features/tasks/data/task_remote_datasource.dart';
import '../../features/tasks/data/task_local_datasource.dart';
import '../../../core/db/app_database.dart';
import 'sync_queue_manager.dart';
import 'conflict_resolver.dart';

class SyncService {
  final SyncQueueManager queueManager;
  final TaskRemoteDataSource remote;
  final TaskLocalDataSource local;
  final ConflictResolver conflictResolver;
  
  bool _isSyncing = false;

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
    _isSyncing = true;
    try {
      final queueItems = await queueManager.getPendingQueue();

      for (final item in queueItems) {
        await queueManager.markQueueSyncing(item.id);

        try {
          if (item.entityType == 'task') {
            if (item.action == 'update') {
               await remote.syncTaskUpdateToServer(item.payload);
            } else if (item.action == 'create') {
               await remote.syncTaskCreateToServer(item.payload);
            }

            // Server update successful!
            // Fetch latest data safely to prevent overriding unseen changes
            final serverData = await remote.fetchLatestServerTaskData(item.entityId);
            
            // Assuming no conflict for simplicity of the flow demo
            final bool hasConflict = await conflictResolver.detectAndHandleConflict(
              item.entityId, 
              jsonDecode(item.payload), 
              serverData
            );

            if (!hasConflict) {
              await queueManager.markQueueCompleted(item.id);
              await local.markTaskSynced(item.entityId);
            } else {
              // Wait for user to resolve conflict
              // Keep queue item or move to failed depending on architecture
               await queueManager.markQueueFailed(item.id, item.retryCount);
            }
          }
        } catch (e) {
          debugPrint('Sync failed for item ${item.id}: $e');
          await queueManager.markQueueFailed(item.id, item.retryCount);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
