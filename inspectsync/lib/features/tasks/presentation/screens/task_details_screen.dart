import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectsync/l10n/app_localizations.dart';
import '../../data/task_repository.dart';
import '../../../../core/db/app_database.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final DateTime _sessionStartedAt;
  late final Stream<DateTime> _timerStream;
  late final ValueNotifier<List<bool>> _checklistNotifier;
  
  final List<String> _checklistItems = [
    "Verify casing integrity",
    "Measure input voltage levels",
    "Clean optical sensor arrays",
    "Seal terminal enclosure",
  ];

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()).asBroadcastStream();
    _checklistNotifier = ValueNotifier<List<bool>>([false, true, false, false]);
  }

  @override
  void dispose() {
    _checklistNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<Task?>(
      future: GetIt.I<TaskRepository>().getTaskById(widget.taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final task = snapshot.data;
        if (task == null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(title: const Text("NOT FOUND")),
            body: const Center(child: Text("Operational directive not found in local cache.")),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 10, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'ENCRYPTED SESSION',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(l10n.taskDetails.toUpperCase(), 
                  style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Mission Header
                    _buildMissionHeader(context, task, l10n),
                    
                    // 2. Technical Checklist
                    _buildSection(
                      context,
                      title: 'OPERATIONAL CHECKLIST',
                      icon: Icons.checklist_rtl_rounded,
                      child: ValueListenableBuilder<List<bool>>(
                        valueListenable: _checklistNotifier,
                        builder: (context, checklist, _) {
                          return Column(
                            children: List.generate(_checklistItems.length, (index) {
                              return _buildChecklistItem(context, index, checklist[index]);
                            }),
                          );
                        },
                      ),
                    ),
                    
                    // 3. Field Evidence (Photos)
                    _buildSection(
                      context,
                      title: 'FIELD EVIDENCE',
                      icon: Icons.camera_enhance_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1581092160562-40aa08e78837?q=80&w=400&fit=crop'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Placeholder(), // Simplified for now
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 4. Tactical Notes
                    _buildSection(
                      context,
                      title: 'TACTICAL NOTES',
                      icon: Icons.notes_rounded,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          maxLines: 4,
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: task.description ?? 'No site protocol found.',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
              
              // Sticky Tactical Footer
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildTacticalFooter(context, l10n, task),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMissionHeader(BuildContext context, Task task, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PROJECT ID:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#OPS-${task.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title.toUpperCase(),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                task.lat != null ? "COORDINATES: ${task.lat}, ${task.lng}" : "LOCATION DATA UNKNOWN",
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildChecklistItem(BuildContext context, int index, bool isDone) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        final current = List<bool>.from(_checklistNotifier.value);
        current[index] = !current[index];
        _checklistNotifier.value = current;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? colorScheme.primary.withValues(alpha: 0.05) : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _checklistItems[index],
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                  color: isDone ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isDone ? colorScheme.primary : colorScheme.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTacticalFooter(BuildContext context, AppLocalizations l10n, Task task) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: StreamBuilder<DateTime>(
                  stream: _timerStream,
                  builder: (context, snapshot) {
                    final now = snapshot.data ?? DateTime.now();
                    final duration = now.difference(_sessionStartedAt);
                    final hours = duration.inHours.toString().padLeft(2, '0');
                    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
                    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                    final elapsedStr = "$hours:$minutes:$seconds";
                    
                    return _buildMetricTile('TIME ON SITE', elapsedStr, Icons.timer_outlined, colorScheme.primary);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<List<bool>>(
                  valueListenable: _checklistNotifier,
                  builder: (context, checklist, _) {
                    final completedCount = checklist.where((v) => v).length;
                    final percent = (completedCount / _checklistItems.length * 100).toInt();
                    return _buildMetricTile('PROGRESS', '$percent%', Icons.analytics_outlined, Colors.orange);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('SUBMIT REPORT TO COMMAND', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: accent),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: accent, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
