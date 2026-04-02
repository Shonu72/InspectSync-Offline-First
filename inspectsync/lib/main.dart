import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'core/db/app_database.dart';
import 'features/sync/conflict_resolver.dart';
import 'features/sync/sync_queue_manager.dart';
import 'features/sync/sync_service.dart';
import 'features/tasks/data/task_local_datasource.dart';
import 'features/tasks/data/task_remote_datasource.dart';
import 'features/tasks/data/task_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Core Services Initialization
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

  runApp(MyApp(taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;

  const MyApp({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InspectSync Offline architecture demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: TasksScreen(repository: taskRepository),
    );
  }
}

class TasksScreen extends StatelessWidget {
  final TaskRepository repository;

  const TasksScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks Sync Demo')),
      body: StreamBuilder<List<Task>>(
        stream: repository.watchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text("No tasks. Press + to add."));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text("Synced: ${task.isSynced}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    final updatedTask = task.copyWith(
                      title: "${task.title} (edited)",
                    );
                    repository.updateTask(updatedTask);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newTask = Task(
            id: const Uuid().v4(),
            title: 'New Task ${DateTime.now().second}',
            status: 'pending',
            version: 1,
            isSynced: false,
            updatedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );
          repository.createTask(newTask);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
