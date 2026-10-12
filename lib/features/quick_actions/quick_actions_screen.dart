import 'package:flutter/material.dart';
import '../../core/services/kelvin_ops_service.dart';
import '../../models/approval_model.dart';
import '../../models/enquiry_model.dart';

class QuickActionsScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const QuickActionsScreen({
    super.key,
    this.onOpenDrawer,
  });

  @override
  State<QuickActionsScreen> createState() => _QuickActionsScreenState();
}

class _QuickActionsScreenState extends State<QuickActionsScreen> with SingleTickerProviderStateMixin {
  final KelvinOpsService _opsService = KelvinOpsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleApproveWithNote(ApprovalModel item) {
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
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
                Text(
                  'Approve ${item.po}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.vendor} • ${item.amount}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add approval note or instruction (optional)...',
                    hintStyle: const TextStyle(fontSize: 13),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A2952) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF2B3D6B) : Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                        label: const Text('Confirm Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _opsService.approvePO(item.id, note: noteController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ ${item.po} approved successfully!'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
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
  }

  void _handleReject(ApprovalModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject PO'),
        content: Text('Are you sure you want to reject ${item.po} (${item.vendor})?'),
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
              _opsService.rejectPO(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${item.po} rejected.'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _handleAssignEnquiry(EnquiryModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign ${item.ref}'),
        content: const Text('Choose a team member to assign this MEP enquiry to:'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          ListTile(
            dense: true,
            leading: const CircleAvatar(backgroundColor: Color(0xFFDBEAFE), child: Text('PS', style: TextStyle(color: Color(0xFF1A56DB)))),
            title: const Text('Priya Shah (Project Manager)'),
            onTap: () {
              Navigator.of(ctx).pop();
              _opsService.assignEnquiry(item.id, 'Priya Shah');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.ref} assigned to Priya Shah!'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          ListTile(
            dense: true,
            leading: const CircleAvatar(backgroundColor: Color(0xFFFEF3C7), child: Text('KN', style: TextStyle(color: Color(0xFFD97706)))),
            title: const Text('Kavya Nair (MEP Engineer)'),
            onTap: () {
              Navigator.of(ctx).pop();
              _opsService.assignEnquiry(item.id, 'Kavya Nair');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.ref} assigned to Kavya Nair!'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleConvertEnquiry(EnquiryModel item) {
    _opsService.convertEnquiryToFollowUp(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lead ${item.ref} logged as active follow-up!'),
        backgroundColor: const Color(0xFF1A56DB),
        behavior: SnackBarBehavior.floating,
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
          final approvals = _opsService.approvals;
          final enquiries = _opsService.enquiries;
          final totalPendingLakhs = approvals.fold<double>(0.0, (sum, a) => sum + a.amountInLakhs);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 14,
                      left: 20,
                      right: 20,
                      bottom: 16,
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
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Approve POs, assign enquiries & take ops action',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFF1A56DB),
                      indicatorWeight: 3,
                      labelColor: const Color(0xFF1A56DB),
                      unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 17),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Approvals (${approvals.length})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mail_outline_rounded, size: 17),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Enquiries (${enquiries.length})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    isDark,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // 1. Approvals Tab
                _buildApprovalsList(approvals, totalPendingLakhs, isDark),

                // 2. Enquiries Tab
                _buildEnquiriesList(enquiries, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApprovalsList(List<ApprovalModel> items, double totalPendingLakhs, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 54, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('All clear!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('No pending Purchase Order approvals', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Pending Value Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total pending approval value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${totalPendingLakhs.toStringAsFixed(1)}L',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
              ),
            ],
          ),
        ),

        // Cards
        ...items.map((item) => _buildApprovalCard(item, isDark)),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildApprovalCard(ApprovalModel item, bool isDark) {
    final isHigh = item.urgency == ApprovalUrgency.high;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D3C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHigh
              ? const Color(0xFFEF4444).withOpacity(0.65)
              : (isDark ? const Color(0xFF1E2D54) : const Color(0xFFE2E8F0)),
          width: isHigh ? 1.5 : 1,
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
          // PO Head
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.po,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.vendor,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.amount,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.urgencyColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.urgencyLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: item.urgencyColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            item.item,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : const Color(0xFF334155)),
          ),
          const SizedBox(height: 6),

          // Days Pending & Requested By
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 13, color: item.days >= 4 ? const Color(0xFFEF4444) : Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Pending ${item.days} day${item.days > 1 ? 's' : ''} • Raised by ${item.requestedBy}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: item.days >= 4 ? FontWeight.w700 : FontWeight.w500,
                    color: item.days >= 4 ? const Color(0xFFEF4444) : Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Urgency Bar
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(99),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: item.urgencyPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: item.urgencyColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons: Reject & Approve
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444)),
                  label: const Text('Reject', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handleReject(item),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                  label: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handleApproveWithNote(item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnquiriesList(List<EnquiryModel> items, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.ref, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(item.client, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: TextStyle(color: item.statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(item.scope, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : const Color(0xFF334155))),
              const SizedBox(height: 10),

              // Chips
              Wrap(
                spacing: 6,
                children: [
                  _buildMetaChip(item.sourceIcon, item.sourceLabel, isDark),
                  _buildMetaChip(Icons.currency_rupee_rounded, item.value, isDark),
                  _buildMetaChip(Icons.access_time_rounded, 'Recently', isDark),
                ],
              ),
              const SizedBox(height: 14),

              // Actions: Assign & Log Follow-up
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_alt_rounded, size: 14, color: Color(0xFF1A56DB)),
                      label: const Text('Assign', style: TextStyle(color: Color(0xFF1A56DB), fontWeight: FontWeight.bold, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF93C5FD)),
                        backgroundColor: const Color(0xFFEFF6FF),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _handleAssignEnquiry(item),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                      label: const Text('Log Follow-up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A56DB),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _handleConvertEnquiry(item),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162347) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _TabBarDelegate(this.tabBar, this.isDark);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? const Color(0xFF0F1A3A) : Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
