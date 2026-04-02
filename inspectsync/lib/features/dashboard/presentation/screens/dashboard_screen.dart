import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectsync/l10n/app_localizations.dart';
import 'package:inspectsync/features/sync/presentation/providers/sync_controller.dart';
import '../../../tasks/presentation/widgets/task_card.dart';

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
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    'JD',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text(
                        'NO INTERNET CONNECTION',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                      if (hasPending || syncController.isSyncing)
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: l10n.taskUnitsRemaining(syncController.pendingItems.length),
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              TextSpan(
                                text: ' ${l10n.remaining.toLowerCase()}',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Empty State: Queue Cleared
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
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
                        ),
                      ],
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
                      // Task List (Now with Priority)
                      TaskCard(
                        title: "Utility Pole Inspection",
                        subtitle: "Sector 7G - Structural integrity audit.",
                        time: "08:30 AM",
                        status: TaskStatus.synced,
                        priority: TaskPriority.high,
                        onTap: () => context.push('/task-details'),
                      ),
                      TaskCard(
                        title: "Substation Delta-9",
                        subtitle: "Manual retry required for 4 attachments.",
                        status: TaskStatus.failed,
                        priority: TaskPriority.high,
                        onTap: () => context.push('/task-details'),
                      ),
                      TaskCard(
                        title: "Water Main Assessment",
                        subtitle: "Awaiting supervisor clearance.",
                        location: "Downtown Plaza",
                        status: TaskStatus.pending,
                        priority: TaskPriority.medium,
                        onTap: () => context.push('/task-details'),
                      ),
                      TaskCard(
                        title: "Fiber Backbone Routing",
                        subtitle: "Optimizing 4.2km trenching path.",
                        status: TaskStatus.inProgress,
                        priority: TaskPriority.low,
                        onTap: () => context.push('/task-details'),
                      ),
                      const SizedBox(height: 24),
                      // Daily Velocity Card
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
                            _buildVelocityRow(context, l10n.target, '15', colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: 12/15,
                                backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildVelocityRow(context, l10n.achieved, '12', Colors.greenAccent),
                            const SizedBox(height: 24),
                            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            Text(
                              l10n.systemHealthy(12),
                              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                            ),
                          ],
                        ),
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
