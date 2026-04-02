import 'package:flutter/foundation.dart';
import '../../sync/sync_service.dart';
import 'task_local_datasource.dart';
import 'task_remote_datasource.dart';
import '../../../core/db/app_database.dart';

class TaskRepository {
  final TaskLocalDataSource local;
  final TaskRemoteDataSource remote;
  final SyncService syncService;

  TaskRepository({
    required this.local,
    required this.remote,
    required this.syncService,
  });

  Stream<List<Task>> watchTasks() {
    return local.watchTasks(); // powers the "UI Auto Refresh"
  }

  Future<void> updateTask(Task task) async {
    // User Action -> Local DB update -> Add to Sync Queue
    await local.updateTaskLocally(task);
    
    // Trigger background sync immediately or rely on intermittent sync runner
    syncService.triggerImmediateSync();
  }

  Future<void> createTask(Task task) async {
    await local.insertTaskLocally(task);
    syncService.triggerImmediateSync();
  }
}
