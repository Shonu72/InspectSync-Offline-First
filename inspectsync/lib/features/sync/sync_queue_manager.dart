import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../../core/db/app_database.dart';

class SyncQueueManager {
  final AppDatabase _db;

  SyncQueueManager(this._db);

  Future<List<SyncQueueData>> getPendingQueue() async {
    return (_db.select(_db.syncQueue)
          ..where((q) => q.status.equals('pending') | q.status.equals('failed'))
          // Prevent hitting things too fast if they keep failing, logic can be added here
          ..orderBy([(q) => drift.OrderingTerm(expression: q.createdAt)]))
        .get();
  }

  Future<void> markQueueSyncing(int id) async {
    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(id)))
        .write(const SyncQueueCompanion(status: drift.Value('syncing')));
  }

  Future<void> markQueueCompleted(int id) async {
    await (_db.delete(_db.syncQueue)..where((q) => q.id.equals(id))).go();
  }

  Future<void> markQueueFailed(int id, int currentRetries) async {
    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(id)))
        .write(SyncQueueCompanion(
          status: const drift.Value('failed'),
          retryCount: drift.Value(currentRetries + 1),
        ));
  }
}
