import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../sync_queue_manager.dart';
import '../../sync_service.dart';

class SyncController extends ChangeNotifier {
  final SyncService _syncService;
  final SyncQueueManager _queueManager;
  final AppDatabase _db;
  final ConnectivityService connectivityService;

  SyncProgress? _currentProgress;
  List<SyncQueueData> _pendingItems = [];
  Map<String, Conflict> _conflicts = {};

  SyncController(
    this._syncService,
    this._queueManager,
    this._db, {
    required this.connectivityService,
  }) {
    _syncService.progressStream.listen((progress) {
      _currentProgress = progress;
      loadData();
      notifyListeners();
    });

    // React to connectivity changes
    connectivityService.addListener(_onConnectivityChanged);

    loadData();
  }

  SyncProgress? get progress => _currentProgress;
  bool get isSyncing => _currentProgress?.isSyncing ?? false;
  List<SyncQueueData> get pendingItems => _pendingItems;
  bool get isOnline => connectivityService.isOnline;
  bool get isOffline => connectivityService.isOffline;
  ConnectivityStatus get connectivityStatus => connectivityService.status;

  void _onConnectivityChanged() {
    // When we come back online, auto-trigger a sync if there are pending items
    if (connectivityService.isOnline && _pendingItems.isNotEmpty && !isSyncing) {
      debugPrint('SyncController: Back online with ${_pendingItems.length} pending → auto-syncing');
      syncNow();
    }
    notifyListeners();
  }

  Future<void> loadData() async {
    _pendingItems = await _queueManager.getPendingQueue();
    final unresolved = await getUnresolvedConflicts();
    _conflicts = {for (var c in unresolved) c.entityId: c};
    notifyListeners();
  }

  Conflict? getConflictForEntity(String entityId) => _conflicts[entityId];

  void syncNow() {
    if (!isSyncing && connectivityService.isOnline) {
      _syncService.triggerImmediateSync();
    } else if (connectivityService.isOffline) {
      debugPrint('SyncController: Cannot sync — device is offline');
    }
  }

  /// Force a connectivity recheck (e.g. user pulls to refresh)
  Future<bool> recheckConnectivity() async {
    return connectivityService.checkNow();
  }

  Future<List<Conflict>> getUnresolvedConflicts() async {
    return (_db.select(
      _db.conflicts,
    )..where((c) => c.status.equals('unresolved'))).get();
  }

  @override
  void dispose() {
    connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
