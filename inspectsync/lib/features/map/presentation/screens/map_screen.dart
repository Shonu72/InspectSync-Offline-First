import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:inspectsync/core/db/app_database.dart';
import 'package:inspectsync/features/tasks/data/task_repository.dart';
import 'package:inspectsync/features/tasks/presentation/screens/task_details_screen.dart';
import 'package:inspectsync/l10n/app_localizations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback? onToggleList;
  const MapScreen({super.key, this.onToggleList});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final ValueNotifier<Task?> _selectedTask;
  late final ValueNotifier<Position?> _currentPosition;
  late final ValueNotifier<String> _distanceText;
  bool _hasInitialBoundsFitted = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTask = ValueNotifier<Task?>(null);
    _currentPosition = ValueNotifier<Position?>(null);
    _distanceText = ValueNotifier<String>("---");

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _determinePosition();
  }

  @override
  void dispose() {
    _selectedTask.dispose();
    _currentPosition.dispose();
    _distanceText.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    _currentPosition.value = position;

    // Listen for updates
    Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        _currentPosition.value = position;
        if (_selectedTask.value != null) {
          _updateDistance();
        }
      }
    });
  }

  void _updateDistance() {
    final pos = _currentPosition.value;
    final task = _selectedTask.value;
    if (pos != null && task != null && task.lat != null && task.lng != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        task.lat!,
        task.lng!,
      );

      final miles = distanceInMeters / 1609.34;
      _distanceText.value = "${miles.toStringAsFixed(1)} mi";
    } else {
      _distanceText.value = "---";
    }
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final taskRepository = GetIt.I<TaskRepository>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: StreamBuilder<List<Task>>(
        stream: taskRepository.watchTasks(),
        builder: (context, snapshot) {
          final tasks =
              snapshot.data
                  ?.where((t) => t.lat != null && t.lng != null)
                  .toList() ??
              [];

          // Tactical Auto-Fit: Ensure all tasks are visible on first load
          if (tasks.isNotEmpty && !_hasInitialBoundsFitted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final points = tasks.map((t) => LatLng(t.lat!, t.lng!)).toList();
                final bounds = LatLngBounds.fromPoints(points);
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(70),
                  ),
                );
                setState(() => _hasInitialBoundsFitted = true);
              }
            });
          }

          final markers = tasks.map((task) {
            final point = LatLng(task.lat!, task.lng!);

            // Tactical Priority Mapping
            final pInt = task.priority;
            final markerColor = pInt == 0
                ? const Color(0xFFD32F2F) // P1: Red
                : (pInt == 1
                      ? const Color(0xFFFBC02D)
                      : const Color(0xFF757575)); // P2: Yellow, P3: Gray

            return Marker(
              point: point,
              width: 80,
              height: 80,
              alignment: Alignment.topCenter,
              child: ValueListenableBuilder<Task?>(
                valueListenable: _selectedTask,
                builder: (context, selected, _) {
                  final isSelected = selected?.id == task.id;
                  return GestureDetector(
                    onTap: () {
                      _selectedTask.value = task;
                      _updateDistance();
                      _mapController.move(point, 15);
                    },
                    child: _buildPointerMarker(
                      context,
                      "#TSK-${task.id.substring(0, 4).toUpperCase()}",
                      isSelected,
                      markerColor,
                    ),
                  );
                },
              ),
            );
          }).toList();

          return Stack(
            children: [
              // 1. Interactive Map with Obsidian Filter
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: tasks.isNotEmpty
                      ? LatLng(tasks.first.lat!, tasks.first.lng!)
                      : const LatLng(34.0522, -118.2437),
                  initialZoom: 14,
                  onTap: (tapPosition, point) => _selectedTask.value = null,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.inspectsync.app',
                    tileBuilder: (context, tileWidget, tile) {
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -0.2,
                          -0.2,
                          -0.2,
                          0,
                          255,
                          -0.2,
                          -0.2,
                          -0.2,
                          0,
                          255,
                          -0.1,
                          -0.1,
                          0.2,
                          0,
                          255,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            colorScheme.surface.withValues(alpha: 0.6),
                            BlendMode.hardLight,
                          ),
                          child: tileWidget,
                        ),
                      );
                    },
                  ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(40, 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(50),
                      maxZoom: 15,
                      markers: markers,
                      builder: (context, markers) {
                        return _buildClusterWidget(context, markers.length);
                      },
                    ),
                  ),
                  // User Location Marker Layer
                  ValueListenableBuilder<Position?>(
                    valueListenable: _currentPosition,
                    builder: (context, pos, _) {
                      if (pos == null) return const SizedBox.shrink();
                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(pos.latitude, pos.longitude),
                            width: 80,
                            height: 80,
                            child: _buildPulsingUserMarker(context),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              // 2. Tactical Controls & Overlays
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: _buildSearchBar(context, l10n),
              ),

              // 3. Dynamic Task Summary Overlay
              ValueListenableBuilder<Task?>(
                valueListenable: _selectedTask,
                builder: (context, selected, _) {
                  final isShowing = selected != null;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutQuart,
                    bottom: isShowing ? 32 : -600,
                    left: 16,
                    right: 16,
                    child: isShowing
                        ? _buildTaskDetailCard(context, l10n, selected)
                        : Container(), // Use Container to avoid issues with AnimatedPositioned children
                  );
                },
              ),

              // 4. Tactical Side Controls
              Positioned(
                right: 16,
                bottom: 350, // Floating above the card
                child: Column(
                  children: [
                    _buildTacticalFab(
                      context,
                      icon: Icons.list_alt_rounded,
                      onPressed: widget.onToggleList ?? () => context.go('/dashboard'),
                      heroTag: 'map_list_fab',
                    ),
                    const SizedBox(height: 12),
                    _buildTacticalFab(
                      context,
                      icon: Icons.add_rounded,
                      onPressed: () {
                        _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                      },
                      heroTag: 'map_zoom_in',
                    ),
                    const SizedBox(height: 12),
                    _buildTacticalFab(
                      context,
                      icon: Icons.remove_rounded,
                      onPressed: () {
                        _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                      },
                      heroTag: 'map_zoom_out',
                    ),
                    const SizedBox(height: 12),
                    _buildTacticalFab(
                      context,
                      icon: Icons.my_location_rounded,
                      onPressed: () {
                        final pos = _currentPosition.value;
                        if (pos != null) {
                          _mapController.move(
                            LatLng(pos.latitude, pos.longitude),
                            15,
                          );
                        }
                      },
                      heroTag: 'map_recenter_fab',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPointerMarker(
    BuildContext context,
    String id,
    bool isSelected,
    Color markerColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ID Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: markerColor.withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            id,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Pointer Pin
        Icon(
          Icons.location_on_rounded,
          size: isSelected ? 42 : 32,
          color: markerColor,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
            if (isSelected)
              Shadow(
                color: markerColor.withValues(alpha: 0.8),
                blurRadius: 20,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildClusterWidget(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTacticalFab(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        mini: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        onPressed: onPressed,
        elevation: 0,
        shape: CircleBorder(
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailCard(
    BuildContext context,
    AppLocalizations l10n,
    Task task,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Tactical Mapping: Priority
    final pInt = task.priority;
    final priorityLabel = pInt == 0
        ? "P1 - HIGH"
        : (pInt == 2 ? "P3 - LOW" : "P2 - MED");
    final priorityColor = pInt == 0
        ? const Color(0xFFD32F2F)
        : (pInt == 2 ? const Color(0xFF388E3C) : const Color(0xFFFBC02D));

    // Tactical Mapping: Time Window (Estimated 4h window from creation)
    final startTime = DateFormat.Hm().format(task.createdAt);
    final endTime = DateFormat.Hm().format(
      task.createdAt.add(const Duration(hours: 4)),
    );
    final timeWindow = "$startTime - $endTime";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Priority Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#TSK-${task.id.substring(0, 8).toUpperCase()}",
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: priorityColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  priorityLabel,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title and Structural Context
          Text(
            task.title.toUpperCase(),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.business_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.description?.toUpperCase() ?? "MAIN BUILDING - SECTOR B",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Info Grid: Distance and Time Window
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  context,
                  Icons.near_me_rounded,
                  "DISTANCE",
                  _distanceText.value,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoBox(
                  context,
                  Icons.access_time_filled_rounded,
                  "TIME WINDOW",
                  timeWindow,
                  color: const Color(
                    0xFF7B1FA2,
                  ), // Tactical Purple for scheduling
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Terminal Actions
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () => _launchNavigation(task.lat!, task.lng!),
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('ROUTE'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskDetailsScreen(taskId: task.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: const Text('START FIELD TASK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeColor = color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: themeColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingUserMarker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outward pulse
            Container(
              width: 25 + (35 * _pulseAnimation.value),
              height: 25 + (35 * _pulseAnimation.value),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.3 * (1 - _pulseAnimation.value),
                ),
                shape: BoxShape.circle,
              ),
            ),
            // Inner core
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}
