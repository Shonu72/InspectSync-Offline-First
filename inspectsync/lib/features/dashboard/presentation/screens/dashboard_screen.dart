import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectsync/l10n/app_localizations.dart';
import 'package:inspectsync/features/sync/presentation/providers/sync_controller.dart';
import 'package:inspectsync/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:inspectsync/features/auth/presentation/bloc/auth_state.dart';
import 'package:inspectsync/features/tasks/data/task_repository.dart';
import 'package:inspectsync/features/tasks/presentation/widgets/task_card.dart';
import 'package:inspectsync/core/db/app_database.dart';

class DashboardScreen extends StatelessWidget {
  final SyncController syncController;
  const DashboardScreen({super.key, required this.syncController});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: syncController,
      builder: (context, child) {
        final isSyncing = syncController.isSyncing;
        final hasPending = syncController.pendingItems.isNotEmpty;
        final isOffline = syncController.isOffline;
        final l10n = AppLocalizations.of(context)!;
        
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: Row(
              children: [
                Icon(
                  isSyncing ? Icons.sync_rounded : (isOffline ? Icons.cloud_off : Icons.cloud_done), 
                  color: isSyncing ? colorScheme.primary : (isOffline ? Colors.orange : Colors.green),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.precisionField,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isSyncing ? 'SYNCING...' : (isOffline ? 'OFFLINE' : 'ONLINE'),
                      style: TextStyle(
                        fontSize: 9, 
                        fontWeight: FontWeight.bold, 
                        color: isSyncing ? colorScheme.primary : (isOffline ? Colors.orange : Colors.green),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              InkWell(
                onTap: () => context.push('/profile'),
                borderRadius: BorderRadius.circular(16),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    String initials = 'JD'; // Default
                    if (state is AuthAuthenticated) {
                      final name = state.user.name;
                      if (name != null && name.isNotEmpty) {
                        final names = name.split(' ');
                        initials = names
                            .where((n) => n.isNotEmpty)
                            .map((n) => n[0])
                            .take(2)
                            .join()
                            .toUpperCase();
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              if (isOffline)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFE53935), // Red for no internet
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        l10n.noInternet.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else if (hasPending && !isSyncing)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF57C00), // Warning Orange
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text(
                        'CHANGES CACHED LOCALLY — AWAITING SYNC',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Dynamic Sync Status Strip
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSyncing ? Icons.sync : (isOffline ? Icons.signal_wifi_off : (hasPending ? Icons.cloud_queue : Icons.cloud_done)), 
                              color: isSyncing ? colorScheme.primary : (isOffline ? Colors.red : (hasPending ? Colors.orange : Colors.green)), 
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isSyncing 
                                  ? 'Synchronizing operational telemetry...' 
                                  : (isOffline 
                                    ? 'Device offline — data secured locally'
                                    : (hasPending ? '${syncController.pendingItems.length} items awaiting upload' : l10n.allLocalDataSynchronized)),
                                style: textTheme.bodySmall?.copyWith(fontSize: 11),
                              ),
                            ),
                            Text(
                              isSyncing 
                                ? '${((syncController.progress?.progress ?? 0) * 100).toInt()}%' 
                                : (isOffline ? 'OFFLINE' : 'UP TO DATE'),
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isSyncing ? colorScheme.primary : (isOffline ? Colors.red : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Active Operations Header
                      Text(
                        l10n.activeOperations,
                        style: textTheme.labelMedium?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Task Management Logic
                      StreamBuilder<List<Task>>(
                        stream: GetIt.I<TaskRepository>().watchTasks(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ));
                          }

                          final tasks = snapshot.data ?? [];
                          final syncedCount = tasks.where((t) => t.isSynced).length;
                          final totalCount = tasks.length;
                          
                          if (tasks.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),
                                  Icon(Icons.check_circle_outline, size: 64, color: colorScheme.primary.withValues(alpha: 0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Queue Cleared",
                                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "All field documentation is synced with command.",
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            key: ValueKey(tasks.length),
                            children: [
                              ...tasks.take(3).map((Task t) {
                                  final pInt = t.priority;
                                  final priority = pInt == 0 ? TaskPriority.high : (pInt == 2 ? TaskPriority.low : TaskPriority.medium);

                                  return TaskCard(
                                    title: t.title,
                                    subtitle: t.description ?? 'No protocol specified',
                                    time: "${t.updatedAt.hour}:${t.updatedAt.minute.toString().padLeft(2, '0')}",
                                    status: t.isSynced ? TaskStatus.synced : TaskStatus.pending,
                                    priority: priority,
                                    onTap: () => context.push('/task/${t.id}'),
                                  );
                              }),
                              
                              const SizedBox(height: 24),
                              // List/Map Toggle
                              Row(
                                children: [
                                  _buildToggleButton(context, l10n.listTab, Icons.list, true),
                                  const SizedBox(width: 8),
                                  _buildToggleButton(context, l10n.mapTab, Icons.map, false),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Daily Velocity Card (Dynamic)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.dailyVelocity,
                                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildVelocityRow(context, "TOTAL ASSIGNMENTS", '$totalCount', colorScheme.onSurfaceVariant),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: totalCount > 0 ? syncedCount / totalCount : 0,
                                        backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildVelocityRow(context, "SYNCED TO COMMAND", '$syncedCount', Colors.greenAccent),
                                    const SizedBox(height: 24),
                                    Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.systemHealthy(syncedCount),
                                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(BuildContext context, String label, IconData icon, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.surfaceContainerLowest : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVelocityRow(BuildContext context, String label, String value, Color valueColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
