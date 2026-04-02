import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/sync_controller.dart';

class SyncStatusScreen extends StatelessWidget {
  final SyncController controller;

  const SyncStatusScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSyncProgressCard(context),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildHistoryCard(context)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStorageCard(context)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildQueueHeader(context),
                const SizedBox(height: 12),
                _buildQueueList(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOnline = controller.isOnline;
    final statusColor = isOnline ? Colors.green : Colors.red;
    final statusLabel = isOnline ? 'ONLINE' : 'OFFLINE';

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Precision Field',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSyncProgressCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = controller.progress?.progress ?? 0.0;
    final isSyncing = controller.isSyncing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: colorScheme.primary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT OPERATIONS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Syncing Field Data',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                ],
              ),
              Icon(Icons.sync, color: colorScheme.primary, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSyncing 
              ? controller.progress?.currentItemDescription ?? 'Preparing...' 
              : 'Waiting for manual sync or connection change...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isSyncing ? null : () => controller.syncNow(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sync Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Text('Cancel All', style: TextStyle(color: colorScheme.onSurface)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, color: colorScheme.onSurfaceVariant, size: 16),
          Text('LAST SUCCESSFUL SYNC', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8)),
          const SizedBox(height: 12),
          Text('14:22', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 10)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('STABLE', style: TextStyle(color: Colors.green.shade700, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.offline_pin, color: Colors.green.shade700, size: 16),
          Text('LOCAL STORAGE', style: TextStyle(color: Colors.green.shade700, fontSize: 8, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('1.2 GB', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          Text('Cached', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildQueueHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.pendingItems.length} ITEMS',
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        IconButton(icon: Icon(Icons.sort, size: 20, color: colorScheme.onSurfaceVariant), onPressed: () {}),
      ],
    );
  }

  Widget _buildQueueList(BuildContext context) {
    final items = controller.pendingItems;
    if (items.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text('No items in queue', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildQueueItem(context, items[index]),
    );
  }

  Widget _buildQueueItem(BuildContext context, dynamic item) {
    final colorScheme = Theme.of(context).colorScheme;
    Color indicatorColor = Colors.grey;
    String statusText = 'PENDING';
    bool hasConflict = item.status == 'failed';

    if (item.status == 'syncing') {
      indicatorColor = colorScheme.primary;
      statusText = 'UPLOADING';
    } else if (item.status == 'completed') {
      indicatorColor = Colors.green;
      statusText = 'SYNCED';
    } else if (hasConflict) {
      indicatorColor = Colors.red;
      statusText = 'CONFLICT';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasConflict 
          ? Colors.red.withValues(alpha: 0.06) 
          : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: hasConflict 
          ? Border.all(color: Colors.red.withValues(alpha: 0.2)) 
          : Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.entityType.toUpperCase()}: ${item.entityId}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface),
                ),
                Text(
                  'Payload size: ${item.payload.length} bytes',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ),
          if (hasConflict)
            TextButton(
              onPressed: () async {
                var conflict = controller.getConflictForEntity(item.entityId);
                
                if (conflict == null) {
                  await controller.loadData();
                  conflict = controller.getConflictForEntity(item.entityId);
                }

                debugPrint('Resolving item: ${item.entityId}, Has conflict: ${conflict != null}');
                
                if (conflict != null && context.mounted) {
                  context.push('/sync/conflict/${item.entityId}', extra: conflict);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Conflict record NOT FOUND in database for ID: ${item.entityId.substring(0, 8)}...'),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'RETRY SYNC',
                        textColor: Colors.white,
                        onPressed: () => controller.syncNow(),
                      ),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('RESOLVE', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            Text(statusText, style: TextStyle(color: indicatorColor, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
