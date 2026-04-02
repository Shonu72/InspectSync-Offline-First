import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectsync/main.dart';
import 'package:inspectsync/core/db/app_database.dart';
import 'package:inspectsync/features/sync/sync_queue_manager.dart';
import 'package:inspectsync/features/sync/conflict_resolver.dart';
import 'package:inspectsync/features/sync/sync_service.dart';
import 'package:inspectsync/features/tasks/data/task_local_datasource.dart';
import 'package:inspectsync/features/tasks/data/task_remote_datasource.dart';
import 'package:inspectsync/features/tasks/data/task_repository.dart';

void main() {
  testWidgets('Offline architecture stub test', (WidgetTester tester) async {
    // Basic service mocking for the test
    final db = AppDatabase();
    final localTaskDs = TaskLocalDataSource(db);
    final remoteTaskDs = TaskRemoteDataSource();
    
    final queueManager = SyncQueueManager(db);
    final conflictResolver = ConflictResolver(db);

    final syncService = SyncService(
      queueManager: queueManager,
      remote: remoteTaskDs,
      local: localTaskDs,
      conflictResolver: conflictResolver,
    );

    final taskRepository = TaskRepository(
      local: localTaskDs,
      remote: remoteTaskDs,
      syncService: syncService,
    );

    await tester.pumpWidget(MyApp(taskRepository: taskRepository));

    expect(find.text('Tasks Sync Demo'), findsOneWidget);
  });
}
