import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectsync/l10n/app_localizations.dart';
import 'package:inspectsync/features/map/presentation/screens/map_screen.dart';
import 'package:inspectsync/features/tasks/presentation/screens/tasks_screen.dart';
import 'dashboard_screen.dart';
import 'package:inspectsync/features/sync/presentation/providers/sync_controller.dart';

class MainScreen extends StatefulWidget {
  final SyncController syncController;
  const MainScreen({super.key, required this.syncController});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(syncController: widget.syncController),
      const MapScreen(),
      const TasksScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, l10n.bottomNavDashboard),
            _buildNavItem(1, Icons.map_rounded, l10n.bottomNavMap),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(2, Icons.assignment_rounded, l10n.bottomNavTasks),
            _buildNavItem(3, Icons.sync_rounded, "SYNC", isRedirect: true), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-task'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool isRedirect = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedIndex == index && !isRedirect;

    return InkWell(
      onTap: () {
        if (isRedirect) {
          context.push('/sync');
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
