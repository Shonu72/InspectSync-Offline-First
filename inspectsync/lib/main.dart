import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';
import 'core/db/app_database.dart';
import 'core/network/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/main_screen.dart';
import 'features/sync/conflict_resolver.dart';
import 'features/sync/sync_queue_manager.dart';
import 'features/sync/sync_service.dart';
import 'features/sync/presentation/providers/sync_controller.dart';
import 'features/sync/presentation/screens/sync_status_screen.dart';
import 'features/sync/presentation/screens/conflict_resolution_screen.dart';
import 'features/tasks/presentation/screens/task_details_screen.dart';
import 'features/tasks/presentation/screens/create_task_screen.dart';
import 'features/tasks/data/task_local_datasource.dart';
import 'features/tasks/data/task_remote_datasource.dart';
import 'features/tasks/data/task_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  final connectivityService = ConnectivityService();

  final syncController = SyncController(
    syncService,
    queueManager,
    db,
    connectivityService: connectivityService,
  );

  final taskRepository = TaskRepository(
    local: localTaskDs,
    remote: remoteTaskDs,
    syncService: syncService,
  );

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => MainScreen(syncController: syncController),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => SyncStatusScreen(controller: syncController),
      ),
      GoRoute(
        path: '/sync/conflict/:id',
        builder: (context, state) {
          final conflict = state.extra as Conflict;
          return ConflictResolutionScreen(conflict: conflict, db: db);
        },
      ),
      GoRoute(
        path: '/task-details',
        builder: (context, state) => const TaskDetailsScreen(),
      ),
      GoRoute(
        path: '/create-task',
        builder: (context, state) => const CreateTaskScreen(),
      ),
    ],
  );

  runApp(MyApp(router: router, taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final TaskRepository taskRepository;

  const MyApp({super.key, required this.router, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'InspectSync Offline architecture demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
