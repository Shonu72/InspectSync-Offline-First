import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/db/app_database.dart';

class TaskLocalDataSource {
  final AppDatabase _db;

  TaskLocalDataSource(this._db);

  Stream<List<Task>> watchTasks() {
    return _db.select(_db.tasks).watch();
  }

  Future<void> updateTaskLocally(Task task) async {
    await _db.transaction(() async {
      // 1. Update local DB
      await _db.update(_db.tasks).replace(task.copyWith(updatedAt: DateTime.now()));

      // 2. Add to Sync Queue
      final payload = jsonEncode({
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'isSynced': task.isSynced,
        // serialize other properties...
      });

      await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
            entityId: task.id,
            entityType: 'task',
            action: 'update',
            payload: payload,
            createdAt: DateTime.now(),
          ));
    });
  }

  Future<void> insertTaskLocally(Task task) async {
    await _db.transaction(() async {
      await _db.into(_db.tasks).insert(task);

      final payload = jsonEncode({'id': task.id}); // full payload
      await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
            entityId: task.id,
            entityType: 'task',
            action: 'create',
            payload: payload,
            createdAt: DateTime.now(),
          ));
    });
  }

  // Update specific task state post-sync
  Future<void> markTaskSynced(String taskId) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId)))
        .write(const TasksCompanion(isSynced: Value(true)));
  }
}
