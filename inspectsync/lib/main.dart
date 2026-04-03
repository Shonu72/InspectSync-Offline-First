import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/db/app_database.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/network/connectivity_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/sync/conflict_resolver.dart';
import 'features/sync/sync_queue_manager.dart';
import 'features/sync/sync_service.dart';
import 'features/sync/presentation/providers/sync_controller.dart';
import 'features/tasks/data/task_local_datasource.dart';
import 'features/tasks/data/task_remote_datasource.dart';
import 'features/tasks/data/task_repository.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();

  // Temporary manual DI for features until they are refactored
  // These will move into di.init() once migrated to Clean Architecture
  final db = sl<AppDatabase>();
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

  final syncController = SyncController(
    syncService,
    queueManager,
    db,
    connectivityService: sl<ConnectivityService>(),
  );

  final taskRepository = TaskRepository(
    local: localTaskDs,
    remote: remoteTaskDs,
    syncService: syncService,
  );

  final authCubit = sl<AuthCubit>();
  await authCubit.checkStatus();

  final router = AppRouter.createRouter(authCubit, syncController, db);

  runApp(
    BlocProvider.value(
      value: authCubit,
      child: MyApp(router: router, taskRepository: taskRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final dynamic router; // GoRouter type
  final TaskRepository taskRepository;

  const MyApp({super.key, required this.router, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'InspectSync Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

