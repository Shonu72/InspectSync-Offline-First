import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/theme/app_theme.dart';

class ConflictResolutionScreen extends StatefulWidget {
  final Conflict conflict;
  final AppDatabase db;

  const ConflictResolutionScreen({
    super.key,
    required this.conflict,
    required this.db,
  });

  @override
  State<ConflictResolutionScreen> createState() => _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen> {
  late Map<String, dynamic> localData;
  late Map<String, dynamic> serverData;
  final Map<String, bool> selectedIsLocal = {}; 
  final Set<String> conflictingKeys = {};

  @override
  void initState() {
    super.initState();
    localData = jsonDecode(widget.conflict.localData);
    serverData = jsonDecode(widget.conflict.serverData);

    final ignoreKeys = {'version', 'updatedAt', 'isSynced'};
    localData.forEach((key, localValue) {
      if (ignoreKeys.contains(key)) return;
      if (serverData.containsKey(key)) {
        final serverValue = serverData[key];
        if (localValue.toString() != serverValue.toString()) {
          conflictingKeys.add(key);
          selectedIsLocal[key] = true; 
        }
      }
    });
  }

  void _resolve() async {
    final Map<String, dynamic> resolvedData = Map.from(serverData);
    selectedIsLocal.forEach((key, isLocal) {
      if (isLocal) {
        resolvedData[key] = localData[key];
      } else {
        resolvedData[key] = serverData[key];
      }
    });

    if (widget.conflict.entityId.isNotEmpty) {
      await (widget.db.update(widget.db.conflicts)..where((c) => c.id.equals(widget.conflict.id)))
          .write(const ConflictsCompanion(status: drift.Value('resolved')));
      
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Conflict Resolution', style: TextStyle(fontSize: 18, color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildBulkActions(),
                  const SizedBox(height: 24),
                  ...conflictingKeys.map((key) => _buildConflictCard(key)).toList(),
                  _buildFinalReview(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Removed bottom nav - managed by MainScreen or simply not needed here
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 12),
              SizedBox(width: 4),
              Text(
                'DATA CONFLICT DETECTED',
                style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sync Conflict: Asset #${widget.conflict.entityId.length > 4 ? widget.conflict.entityId.substring(0, 4) : widget.conflict.entityId}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Keep local changes or server updates? Select for each field.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () { setState(() { for (var key in conflictingKeys) { selectedIsLocal[key] = false; } }); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0E0E0), foregroundColor: Colors.black, elevation: 0),
            child: const Text('Server All'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () { setState(() { for (var key in conflictingKeys) { selectedIsLocal[key] = true; } }); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, elevation: 0),
            child: const Text('Local All'),
          ),
        ),
      ],
    );
  }

  Widget _buildConflictCard(String key) {
    final isLocal = selectedIsLocal[key] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key.toUpperCase(), style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDataBlock(title: 'LOCAL', content: localData[key].toString(), isSelected: isLocal, onSelect: () => setState(() => selectedIsLocal[key] = true), isPrimary: true, fieldName: key),
            const SizedBox(height: 12),
            _buildDataBlock(title: 'SERVER', content: serverData[key].toString(), isSelected: !isLocal, onSelect: () => setState(() => selectedIsLocal[key] = false), isPrimary: false, fieldName: key),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBlock({required String title, required String content, required bool isSelected, required VoidCallback onSelect, required bool isPrimary, required String fieldName}) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: isSelected ? AppTheme.primary : const Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: isSelected ? AppTheme.primary : Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isPrimary ? AppTheme.primary : Colors.grey)),
              Text(content, style: const TextStyle(fontSize: 14)),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalReview() {
    return ElevatedButton(
      onPressed: _resolve,
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Text('Commit & Resolve All', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
