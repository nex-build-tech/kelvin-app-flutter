import 'package:flutter/material.dart';
import '../../core/services/kelvin_ops_service.dart';
import '../../models/reminder_model.dart';

class RemindersScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const RemindersScreen({
    super.key,
    this.onOpenDrawer,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final KelvinOpsService _opsService = KelvinOpsService();

  void _openAddReminderSheet() {
    final titleController = TextEditingController();
    String selectedPriority = 'medium';
    String selectedType = 'task';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111D3C) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'New Reminder',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),

                    // Title Input
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'What do you need to remember?',
                        hintStyle: const TextStyle(fontSize: 13),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A2952) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF2B3D6B) : Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Type Selector
                    const Text('REMINDER TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['call', 'report', 'approval', 'visit', 'task'].map((t) {
                        final isSel = selectedType == t;
                        return Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => selectedType = t),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF1A56DB) : (isDark ? const Color(0xFF162347) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  t[0].toUpperCase() + t.substring(1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    color: isSel ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Priority Selector
                    const Text('PRIORITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['high', 'medium', 'low'].map((p) {
                        final isSel = selectedPriority == p;
                        final color = p == 'high'
                            ? const Color(0xFFEF4444)
                            : (p == 'medium' ? const Color(0xFFF59E0B) : const Color(0xFF64748B));
                        return Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => selectedPriority = p),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel ? color.withOpacity(0.15) : (isDark ? const Color(0xFF162347) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSel ? color : Colors.transparent, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    p[0].toUpperCase() + p.substring(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                      color: isSel ? color : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.alarm_add_rounded, color: Colors.white, size: 18),
                            label: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A56DB),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              final text = titleController.text.trim();
                              if (text.isEmpty) return;
                              Navigator.of(ctx).pop();
                              _opsService.addReminder(
                                ReminderModel(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  title: text,
                                  time: DateTime.now().add(const Duration(hours: 1)),
                                  type: selectedType,
                                  priority: selectedPriority,
                                  repeat: 'none',
                                  isDone: false,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reminder added!'), behavior: SnackBarBehavior.floating),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleDelete(ReminderModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Remove "${item.title}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _opsService.deleteReminder(item.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1128) : const Color(0xFFF8FAFC),
      body: ListenableBuilder(
        listenable: _opsService,
        builder: (context, _) {
          final all = _opsService.reminders;
          final today = DateTime.now();

          final todayReminders = all.where((r) => !r.isDone && r.time.year == today.year && r.time.month == today.month && r.time.day == today.day).toList();
          final upcomingReminders = all.where((r) => !r.isDone && r.time.isAfter(DateTime(today.year, today.month, today.day, 23, 59))).toList();
          final doneReminders = all.where((r) => r.isDone).toList();

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 14,
                    left: 20,
                    right: 20,
                    bottom: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B1F68),
                    gradient: LinearGradient(
                      colors: [Color(0xFF071448), Color(0xFF0D2B8F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (widget.onOpenDrawer != null) ...[
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                                onPressed: widget.onOpenDrawer,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reminders',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${todayReminders.length} due today • ${upcomingReminders.length} upcoming',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Add Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1A56DB),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 22),
                        onPressed: _openAddReminderSheet,
                      ),
                    ],
                  ),
                ),
              ),

              // Content Sections
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSection('Today', todayReminders, const Color(0xFFEF4444), isDark),
                    const SizedBox(height: 16),
                    _buildSection('Upcoming', upcomingReminders, const Color(0xFF1A56DB), isDark),
                    const SizedBox(height: 16),
                    if (doneReminders.isNotEmpty)
                      _buildSection('Completed', doneReminders, const Color(0xFF10B981), isDark),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<ReminderModel> items, Color accentColor, bool isDark) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${items.length})',
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111D3C) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 52,
              color: isDark ? const Color(0xFF1E2D54) : const Color(0xFFF1F5F9),
            ),
            itemBuilder: (context, index) {
              final r = items[index];
              return _buildReminderRow(r, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderRow(ReminderModel r, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Checkbox Icon
          InkWell(
            onTap: () => _opsService.toggleReminder(r.id),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: r.typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                r.isDone ? Icons.check_circle_rounded : r.typeIcon,
                size: 18,
                color: r.isDone ? const Color(0xFF10B981) : r.typeColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: r.isDone ? TextDecoration.lineThrough : null,
                    color: r.isDone ? Colors.grey : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${r.time.hour.toString().padLeft(2, '0')}:${r.time.minute.toString().padLeft(2, '0')} • ${r.repeatLabel}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 5, height: 5, decoration: BoxDecoration(color: r.priorityColor, shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          if (!r.isDone)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey[400]),
              onPressed: () => _handleDelete(r),
            ),
        ],
      ),
    );
  }
}
