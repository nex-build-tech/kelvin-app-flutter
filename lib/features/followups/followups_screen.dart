import 'package:flutter/material.dart';
import '../../core/services/kelvin_ops_service.dart';
import '../../models/follow_up_model.dart';

class FollowUpsScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const FollowUpsScreen({
    super.key,
    this.onOpenDrawer,
  });

  @override
  State<FollowUpsScreen> createState() => _FollowUpsScreenState();
}

class _FollowUpsScreenState extends State<FollowUpsScreen> {
  final KelvinOpsService _opsService = KelvinOpsService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Overdue', 'Due Today', 'Upcoming'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handlePing(FollowUpModel item) {
    String message = '';
    switch (item.channel) {
      case ContactChannel.whatsapp:
        message = 'Hi ${item.contact}, this is a quick follow-up regarding ${item.topic}. Could you please update us at your earliest convenience?';
        break;
      case ContactChannel.call:
        message = 'Initiating phone call to ${item.contact} at ${item.phone} regarding ${item.topic}...';
        break;
      case ContactChannel.email:
        message = 'Drafting formal follow-up email to ${item.contact} for ${item.topic}...';
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(item.channelIcon, color: item.channelColor, size: 22),
            const SizedBox(width: 8),
            Text('Send via ${item.channelLabel}'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: item.channelColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Message sent to ${item.contact} via ${item.channelLabel}!'),
                  backgroundColor: item.channelColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send ✓'),
          ),
        ],
      ),
    );
  }

  void _handleSnooze(FollowUpModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
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
                'Snooze Follow-up',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Snooze notification for ${item.contact} (${item.company})',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time_rounded, color: Color(0xFFF59E0B)),
                title: const Text('1 Hour', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _opsService.snoozeFollowUp(item.id, const Duration(hours: 1));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Follow-up snoozed for 1 hour.'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny_outlined, color: Color(0xFF1A56DB)),
                title: const Text('Tomorrow', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _opsService.snoozeFollowUp(item.id, const Duration(days: 1));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Follow-up snoozed until tomorrow.'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMarkDone(FollowUpModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Complete'),
        content: Text('Mark follow-up with ${item.contact} (${item.company}) as done?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _opsService.markFollowUpDone(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Follow-up with ${item.contact} completed!'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Done ✓'),
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
          final all = _opsService.followUps;
          final overdueCount = all.where((f) => f.status == FollowUpStatus.overdue).length;
          final todayCount = all.where((f) => f.status == FollowUpStatus.dueToday).length;

          // Filter by selected tab and search query
          final query = _searchController.text.trim().toLowerCase();
          final filtered = all.where((f) {
            final matchFilter = _selectedFilter == 'All' ||
                (_selectedFilter == 'Overdue' && f.status == FollowUpStatus.overdue) ||
                (_selectedFilter == 'Due Today' && f.status == FollowUpStatus.dueToday) ||
                (_selectedFilter == 'Upcoming' && f.status == FollowUpStatus.upcoming);

            final matchSearch = query.isEmpty ||
                f.contact.toLowerCase().contains(query) ||
                f.company.toLowerCase().contains(query) ||
                f.topic.toLowerCase().contains(query);

            return matchFilter && matchSearch;
          }).toList();

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                const Flexible(
                                  child: Text(
                                    'Follow-ups',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Quick Stat Chips
                          Row(
                            children: [
                              if (overdueCount > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$overdueCount',
                                        style: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w900, fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'overdue',
                                        style: TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (todayCount > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$todayCount',
                                        style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.w900, fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'today',
                                        style: TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search Input
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search contact, company, or topic...',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF1A56DB)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Tabs
              SliverToBoxAdapter(
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _filters[index];
                      final isSelected = _selectedFilter == f;
                      return ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                        selectedColor: const Color(0xFF1A56DB),
                        backgroundColor: isDark ? const Color(0xFF131D3C) : const Color(0xFFE2E8F0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: isSelected ? const Color(0xFF1A56DB) : Colors.transparent),
                        onSelected: (val) {
                          if (val) setState(() => _selectedFilter = f);
                        },
                      );
                    },
                  ),
                ),
              ),

              // Follow-up List
              if (filtered.isEmpty) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 54, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'All caught up!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No follow-ups pending in this category.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filtered[index];
                        return _buildFollowUpCard(item, isDark);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFollowUpCard(FollowUpModel f, bool isDark) {
    final isOverdue = f.status == FollowUpStatus.overdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D3C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? const Color(0xFFEF4444).withOpacity(0.65)
              : (isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0)),
          width: isOverdue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Company, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.contact,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f.company,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: f.statusBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  f.statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: f.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Topic & Project
          Text(
            f.topic,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[200] : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            f.project,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A56DB),
            ),
          ),
          const SizedBox(height: 12),

          // Actions Row (WhatsApp/Call/Email, Snooze, Done)
          Row(
            children: [
              // Ping Button
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  icon: Icon(f.channelIcon, size: 14, color: f.channelColor),
                  label: Text(
                    f.channelLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: f.channelColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: f.channelColor.withOpacity(0.4)),
                    backgroundColor: f.channelColor.withOpacity(0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handlePing(f),
                ),
              ),
              const SizedBox(width: 8),

              // Snooze Button
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.alarm_rounded, size: 14, color: Color(0xFFF59E0B)),
                  label: const Text(
                    'Snooze',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                    backgroundColor: const Color(0xFFF59E0B).withOpacity(0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handleSnooze(f),
                ),
              ),
              const SizedBox(width: 8),

              // Done Button
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.white),
                  label: const Text(
                    'Done',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handleMarkDone(f),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
