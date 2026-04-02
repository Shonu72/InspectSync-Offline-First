import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectsync/features/tasks/presentation/widgets/task_card.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Tactical Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                'FIELD ASSIGNMENTS',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: colorScheme.primary,
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
              const SizedBox(width: 8),
            ],
          ),
          
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, "ACTIVE DIRECTIVES"),
                const SizedBox(height: 16),
                
                TaskCard(
                  title: "Substation Fiber Inspection",
                  subtitle: "ID: #OPS-2024-99X",
                  location: "North Grid Cluster",
                  time: "09:00 - 11:30",
                  status: TaskStatus.inProgress,
                  priority: TaskPriority.high,
                  onTap: () => context.push('/task-details'),
                ),
                TaskCard(
                  title: "HVAC Circuit Maintenance",
                  subtitle: "ID: #OPS-2024-88B",
                  location: "Industrial Park South",
                  time: "13:00 - 15:30",
                  status: TaskStatus.pending,
                  priority: TaskPriority.medium,
                  onTap: () => context.push('/task-details'),
                ),
                TaskCard(
                  title: "Optical Sensor Calibration",
                  subtitle: "ID: #OPS-2024-77C",
                  location: "Sector 7G Lab",
                  status: TaskStatus.failed,
                  priority: TaskPriority.high,
                  onTap: () => context.push('/task-details'),
                ),
                
                const SizedBox(height: 40),
                _buildSectionHeader(context, "SYSTEM TELEMETRY"),
                const SizedBox(height: 16),
                
                _buildTacticalStatusCard(
                  context,
                  icon: Icons.shield_outlined,
                  title: "ENCRYPTION ACTIVE",
                  subtitle: "End-to-end field data integrity verified.",
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildTacticalStatusCard(
                  context,
                  icon: Icons.cloud_off_rounded,
                  title: "LOCAL CACHE MODE",
                  subtitle: "Offline performance optimization enabled.",
                  color: Colors.orange,
                ),
                
                const SizedBox(height: 48),
                Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Column(
                      children: [
                        const Icon(Icons.terminal_rounded, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          "InspectSync // SECURE TERMINAL v4.2.0",
                          style: textTheme.labelSmall?.copyWith(letterSpacing: 1.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildTacticalStatusCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color, letterSpacing: 1.0),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
