import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/sync/presentation/providers/sync_controller.dart';
import '../../features/sync/presentation/screens/sync_status_screen.dart';
import '../../features/sync/presentation/screens/conflict_resolution_screen.dart';
import '../../features/tasks/presentation/screens/task_details_screen.dart';
import '../../features/tasks/presentation/screens/create_task_screen.dart';
import '../db/app_database.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String sync = '/sync';
  static const String taskDetails = '/task-details';
  static const String createTask = '/create-task';
  static const String conflictResolution = '/sync/conflict/:id';

  static GoRouter createRouter(AuthCubit authCubit, SyncController syncController, AppDatabase db) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: login,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isLoggingIn = state.matchedLocation == login;

        if (!isAuthenticated && !isLoggingIn) return login;
        if (isAuthenticated && isLoggingIn) return dashboard;

        return null;
      },
      routes: [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: dashboard,
          builder: (context, state) => MainScreen(syncController: syncController),
        ),
        GoRoute(
          path: sync,
          builder: (context, state) => SyncStatusScreen(controller: syncController),
        ),
        GoRoute(
          path: conflictResolution,
          builder: (context, state) {
            final conflict = state.extra as Conflict;
            return ConflictResolutionScreen(conflict: conflict, db: db);
          },
        ),
        GoRoute(
          path: taskDetails,
          builder: (context, state) => const TaskDetailsScreen(),
        ),
        GoRoute(
          path: createTask,
          builder: (context, state) => const CreateTaskScreen(),
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
