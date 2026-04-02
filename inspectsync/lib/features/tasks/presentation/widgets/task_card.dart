import 'package:flutter/material.dart';
import 'package:inspectsync/l10n/app_localizations.dart';

enum TaskStatus { synced, failed, pending, inProgress }
enum TaskPriority { low, medium, high }

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? time;
  final String? location;
  final TaskStatus status;
  final TaskPriority priority;
  final VoidCallback? onActionPressed;
  final VoidCallback? onTap;
  final String? imageUrl;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.time,
    this.location,
    required this.status,
    this.priority = TaskPriority.medium,
    this.onActionPressed,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case TaskStatus.synced:
        statusColor = const Color(0xFF4CAF50);
        statusLabel = l10n.synced;
        break;
      case TaskStatus.failed:
        statusColor = const Color(0xFFE53935);
        statusLabel = l10n.failed;
        break;
      case TaskStatus.pending:
        statusColor = Colors.grey;
        statusLabel = l10n.pending;
        break;
      case TaskStatus.inProgress:
        statusColor = colorScheme.primary;
        statusLabel = l10n.inProgress;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Indicator Line
              Container(
                width: 4,
                color: statusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              _buildPriorityBadge(context),
                            ],
                          ),
                          _buildStatusBadge(context, statusLabel, statusColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      if (imageUrl != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              color: colorScheme.surfaceContainer,
                              child: const Icon(Icons.map_outlined),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (time != null) ...[
                            Icon(Icons.access_time,
                                size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              time!,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                          if (location != null) ...[
                            Icon(Icons.location_on_outlined,
                                size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              location!,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                          const Spacer(),
                          if (status == TaskStatus.failed)
                            ElevatedButton(
                              onPressed: onActionPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh, size: 14),
                                  const SizedBox(width: 4),
                                  Text(l10n.retrySync,
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            )
                          else if (status == TaskStatus.inProgress)
                            ElevatedButton(
                              onPressed: onActionPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              child: Text(l10n.continueTask,
                                  style: const TextStyle(fontSize: 12)),
                            )
                          else
                            Icon(Icons.arrow_forward,
                                size: 16, color: colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.synced:
        return Icons.check_circle;
      case TaskStatus.failed:
        return Icons.error;
      case TaskStatus.pending:
        return Icons.more_horiz;
      case TaskStatus.inProgress:
        return Icons.navigation;
    }
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color priorityColor;
    String label;
    switch (priority) {
      case TaskPriority.high:
        priorityColor = const Color(0xFFD32F2F);
        label = 'P1';
        break;
      case TaskPriority.medium:
        priorityColor = const Color(0xFFF57C00);
        label = 'P2';
        break;
      case TaskPriority.low:
        priorityColor = const Color(0xFF388E3C);
        label = 'P3';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priorityColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
