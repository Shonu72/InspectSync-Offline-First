import 'package:flutter/material.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'Zone 04 - Sector B');
  
  int _selectedPriority = 0; // 0=High, 1=Medium, 2=Low
  String _selectedCategory = 'Field Maintenance';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  
  final List<String> _categories = [
    'Field Maintenance',
    'Infrastructure Audit',
    'Sensor Calibration',
    'Emergency Repair',
    'Routine Inspection',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          'Create Task',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TACTICAL ENTRY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New Operation',
                    style: textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Priority Selector
            _buildPrioritySelector(context),
            
            const SizedBox(height: 28),
            
            // Task Title & Description Card
            _buildInputCard(context, isDark),
            
            const SizedBox(height: 16),
            
            // Category & Location Card
            _buildMetaCard(context, isDark),
            
            const SizedBox(height: 16),
            
            // Date & Time Card
            _buildScheduleCard(context),
            
            const SizedBox(height: 28),
            
            // Attachments Section
            _buildAttachmentsSection(context, isDark),
            
            const SizedBox(height: 32),
            
            // Submit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'EXECUTE CREATION',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Priority Toggle ─────────────────────────────────────────
  Widget _buildPrioritySelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labels = ['HIGH', 'MED', 'LOW'];
    final colors = [const Color(0xFFD32F2F), const Color(0xFFF57C00), const Color(0xFF388E3C)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'SET URGENCY',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isSelected = _selectedPriority == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPriority = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? colors[index] : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? colors[index] : colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── Title & Description ─────────────────────────────────────
  Widget _buildInputCard(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TASK TITLE',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
          ),
          TextField(
            controller: _titleController,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'e.g. Infrastructure Diagnostic',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16),
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'DETAILED PROTOCOL',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
          ),
          TextField(
            controller: _descriptionController,
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 14),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the tactical requirements...',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14),
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category & Location ─────────────────────────────────────
  Widget _buildMetaCard(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Category Row
          InkWell(
            onTap: _showCategoryPicker,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.settings_rounded, color: colorScheme.onSurfaceVariant, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CATEGORY',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedCategory,
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurfaceVariant, size: 24),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          // Location Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on, color: colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCATION',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _locationController.text,
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Schedule Card ───────────────────────────────────────────
  Widget _buildScheduleCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // Date Row
          InkWell(
            onTap: _pickDate,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCHEDULED DATE',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}',
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_calendar, color: colorScheme.primary.withValues(alpha: 0.5), size: 20),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.primary.withValues(alpha: 0.1)),
          // Time Row
          InkWell(
            onTap: _pickTime,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LAUNCH TIME',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedTime.format(context),
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.access_time, color: colorScheme.primary.withValues(alpha: 0.5), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Attachments ─────────────────────────────────────────────
  Widget _buildAttachmentsSection(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INTELLIGENCE ATTACHMENTS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5),
              ),
              Text(
                'MAX 50MB',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Add Media Tile
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded, color: colorScheme.primary, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          'ADD MEDIA',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Document Tile
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_file_rounded, color: colorScheme.primary, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          'ATTACH DOC',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.0),
                        ),
                      ],
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

  // ─── Actions ─────────────────────────────────────────────────
  void _showCategoryPicker() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('SELECT CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              ..._categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  title: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title is required'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Operation initialized — queued for sync'),
        backgroundColor: Color(0xFF388E3C),
      ),
    );
    Navigator.pop(context);
  }
}
