import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/approval_model.dart';
import '../../models/enquiry_model.dart';
import '../../models/feed_activity_model.dart';
import '../../models/follow_up_model.dart';
import '../../models/hvac_project_model.dart';
import '../../models/hvac_task_model.dart';
import '../../models/reminder_model.dart';
import 'api_service.dart';
import 'notification_service.dart';

/// Central Kelvin Ops Service managing real-time MEP & HVAC telemetry,
/// approval chains, project milestones, reminders, and follow-ups.
/// Automatically syncs with local MySQL database via REST API.
class KelvinOpsService extends ChangeNotifier {
  static final KelvinOpsService _instance = KelvinOpsService._internal();
  factory KelvinOpsService() => _instance;

  KelvinOpsService._internal() {
    _initData();
    _startLiveSimulation();
    syncFromMySqlBackend();
  }

  // --- Live KPI State ---
  int _kpiTasks = 12;
  int _kpiBreaches = 3;
  int _kpiApprovals = 4;
  int _kpiEnquiries = 7;

  int get kpiTasks => _kpiTasks;
  int get kpiBreaches => _kpiBreaches;
  int get kpiApprovals => _kpiApprovals;
  int get kpiEnquiries => _kpiEnquiries;

  // --- Collections ---
  final List<HvacProjectModel> _projects = [];
  final List<HvacTaskModel> _myTasks = [];
  final List<FollowUpModel> _followUps = [];
  final List<ApprovalModel> _approvals = [];
  final List<EnquiryModel> _enquiries = [];
  final List<ReminderModel> _reminders = [];
  final List<FeedActivityModel> _activityFeed = [];

  List<HvacProjectModel> get projects => List.unmodifiable(_projects);
  List<HvacTaskModel> get myTasks => List.unmodifiable(_myTasks);
  List<FollowUpModel> get followUps => List.unmodifiable(_followUps);
  List<ApprovalModel> get approvals => List.unmodifiable(_approvals);
  List<EnquiryModel> get enquiries => List.unmodifiable(_enquiries);
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  List<FeedActivityModel> get activityFeed => List.unmodifiable(_activityFeed);

  // --- Notification Preferences ---
  final Map<String, bool> _notificationPrefs = {
    'sla': true,
    'approval': true,
    'followup': true,
    'enquiry': false,
    'project': false,
    'report': true,
  };
  Map<String, bool> get notificationPrefs => Map.unmodifiable(_notificationPrefs);

  void toggleNotificationPref(String key) {
    if (_notificationPrefs.containsKey(key)) {
      _notificationPrefs[key] = !(_notificationPrefs[key] ?? false);
      notifyListeners();
    }
  }

  // Timers
  Timer? _kpiTimer;
  Timer? _projectTimer;
  Timer? _feedTimer;
  Timer? _notifTimer;

  final Random _rng = Random();

  void _initData() {
    // 1. Projects
    _projects.addAll([
      const HvacProjectModel(
        id: 1,
        name: 'Airport Terminal T3',
        pct: 62.0,
        status: ProjectStatus.onTrack,
        phase: 'Execution',
        value: '₹4.2 Cr',
        client: 'GMR Airports',
      ),
      const HvacProjectModel(
        id: 2,
        name: 'ABC Tower MEP',
        pct: 88.0,
        status: ProjectStatus.onTrack,
        phase: 'Commissioning',
        value: '₹2.8 Cr',
        client: 'ABC Infra Ltd',
      ),
      const HvacProjectModel(
        id: 3,
        name: 'City Hospital Block-C',
        pct: 45.0,
        status: ProjectStatus.delayed,
        phase: 'Execution',
        value: '₹1.9 Cr',
        client: 'City Corp Hospitals',
      ),
      const HvacProjectModel(
        id: 4,
        name: 'Metro Station MEP',
        pct: 71.0,
        status: ProjectStatus.atRisk,
        phase: 'Execution',
        value: '₹3.1 Cr',
        client: 'Metro Rail Authority',
      ),
      const HvacProjectModel(
        id: 5,
        name: 'Luxe Residences',
        pct: 95.0,
        status: ProjectStatus.onTrack,
        phase: 'Handover',
        value: '₹0.9 Cr',
        client: 'Prestige Group',
      ),
    ]);

    // 2. Daily Tasks
    final now = DateTime.now();
    _myTasks.addAll([
      HvacTaskModel(
        id: 1,
        title: 'Follow up — Voltas AHU delivery',
        project: 'Metro Station MEP',
        due: now.subtract(const Duration(days: 1)),
        priority: 'high',
        isDone: false,
        type: 'followup',
      ),
      HvacTaskModel(
        id: 2,
        title: 'Approve PO-2024-090 — Daikin India',
        project: 'Metro Station MEP',
        due: now,
        priority: 'high',
        isDone: false,
        type: 'approval',
      ),
      HvacTaskModel(
        id: 3,
        title: 'Send BOQ revision to ABC Builders',
        project: 'ABC Tower MEP',
        due: now,
        priority: 'medium',
        isDone: false,
        type: 'task',
      ),
      HvacTaskModel(
        id: 4,
        title: 'Site visit — Sunrise Mall Block A',
        project: 'Sunrise Mall MEP',
        due: now.add(const Duration(days: 1)),
        priority: 'medium',
        isDone: false,
        type: 'visit',
      ),
      HvacTaskModel(
        id: 5,
        title: 'PO-2024-096 — Grundfos Pumps review',
        project: 'City Hospital',
        due: now.add(const Duration(days: 1)),
        priority: 'low',
        isDone: false,
        type: 'approval',
      ),
      HvacTaskModel(
        id: 6,
        title: 'Confirm ETA — Bharat Steel delivery',
        project: 'City Hospital',
        due: now.add(const Duration(days: 2)),
        priority: 'medium',
        isDone: false,
        type: 'followup',
      ),
      HvacTaskModel(
        id: 7,
        title: 'Update progress — Airport T3 (62%)',
        project: 'Airport Terminal T3',
        due: now.add(const Duration(days: 2)),
        priority: 'low',
        isDone: false,
        type: 'update',
      ),
    ]);

    // 3. Follow-ups
    _followUps.addAll([
      FollowUpModel(
        id: 1,
        contact: 'Rajesh Mehta',
        company: 'Voltas Ltd',
        topic: 'AHU Unit delivery ETA confirmation',
        phone: '+91 98765 43210',
        project: 'Metro Station MEP',
        due: now.subtract(const Duration(days: 1)),
        status: FollowUpStatus.overdue,
        channel: ContactChannel.whatsapp,
      ),
      FollowUpModel(
        id: 2,
        contact: 'Anita Sharma',
        company: 'Daikin India',
        topic: 'PO-2024-090 acceptance + payment terms',
        phone: '+91 87654 32109',
        project: 'Metro Station MEP',
        due: now,
        status: FollowUpStatus.dueToday,
        channel: ContactChannel.call,
      ),
      FollowUpModel(
        id: 3,
        contact: 'Sunil Verma',
        company: 'Bharat Steel',
        topic: 'MS Pipes 50m — revised ETA',
        phone: '+91 76543 21098',
        project: 'City Hospital',
        due: now,
        status: FollowUpStatus.dueToday,
        channel: ContactChannel.email,
      ),
      FollowUpModel(
        id: 4,
        contact: 'Priya Kapoor',
        company: 'Carrier HVAC',
        topic: 'AHU Chiller specs confirmation',
        phone: '+91 65432 10987',
        project: 'ABC Tower MEP',
        due: now.add(const Duration(days: 1)),
        status: FollowUpStatus.upcoming,
        channel: ContactChannel.whatsapp,
      ),
      FollowUpModel(
        id: 5,
        contact: 'Mohan Das',
        company: 'Finolex Cables',
        topic: 'Cable delivery to Airport T3 site',
        phone: '+91 54321 09876',
        project: 'Airport Terminal T3',
        due: now.add(const Duration(days: 2)),
        status: FollowUpStatus.upcoming,
        channel: ContactChannel.call,
      ),
      FollowUpModel(
        id: 6,
        contact: 'Kavitha Nair',
        company: 'Armacell India',
        topic: 'Insulation rolls dispatch confirmation',
        phone: '+91 43210 98765',
        project: 'ABC Tower MEP',
        due: now.add(const Duration(days: 3)),
        status: FollowUpStatus.upcoming,
        channel: ContactChannel.email,
      ),
    ]);

    // 4. PO Approvals
    _approvals.addAll([
      const ApprovalModel(
        id: 1,
        po: 'PO-2024-090',
        vendor: 'Daikin India Ltd',
        item: 'VRF Units ×8 — Metro Station',
        amount: '₹29.1L',
        amountInLakhs: 29.1,
        days: 5,
        urgency: ApprovalUrgency.high,
        status: ApprovalStatus.pending,
        requestedBy: 'Priya S',
      ),
      const ApprovalModel(
        id: 2,
        po: 'PO-2024-092',
        vendor: 'Carrier HVAC India',
        item: 'AHU Chillers ×2 — ABC Tower',
        amount: '₹45.0L',
        amountInLakhs: 45.0,
        days: 3,
        urgency: ApprovalUrgency.medium,
        status: ApprovalStatus.pending,
        requestedBy: 'Kavya N',
      ),
      const ApprovalModel(
        id: 3,
        po: 'PO-2024-094',
        vendor: 'ABB India Pvt Ltd',
        item: 'LT Panel Set — Airport T3',
        amount: '₹9.6L',
        amountInLakhs: 9.6,
        days: 2,
        urgency: ApprovalUrgency.medium,
        status: ApprovalStatus.pending,
        requestedBy: 'Priya S',
      ),
      const ApprovalModel(
        id: 4,
        po: 'PO-2024-096',
        vendor: 'Grundfos Pumps',
        item: 'Pump Set ×6 — City Hospital',
        amount: '₹12.0L',
        amountInLakhs: 12.0,
        days: 1,
        urgency: ApprovalUrgency.low,
        status: ApprovalStatus.pending,
        requestedBy: 'Suresh I',
      ),
    ]);

    // 5. Enquiries
    _enquiries.addAll([
      EnquiryModel(
        id: 1,
        ref: 'ENQ-461',
        client: 'Greenfield Developers',
        scope: 'Residential Tower MEP — Bengaluru',
        value: '~₹3.2 Cr',
        source: EnquirySource.whatsapp,
        received: now.subtract(const Duration(hours: 2)),
        status: EnquiryStatus.newLead,
        priority: 'high',
      ),
      EnquiryModel(
        id: 2,
        ref: 'ENQ-460',
        client: 'DLF Infra Ltd',
        scope: 'Commercial Complex HVAC — Pune',
        value: '~₹1.8 Cr',
        source: EnquirySource.email,
        received: now.subtract(const Duration(hours: 4)),
        status: EnquiryStatus.contacted,
        priority: 'medium',
      ),
      EnquiryModel(
        id: 3,
        ref: 'ENQ-458',
        client: 'Prestige Group',
        scope: 'Hotel MEP — Chennai',
        value: '~₹5.1 Cr',
        source: EnquirySource.referral,
        received: now.subtract(const Duration(days: 1)),
        status: EnquiryStatus.siteVisit,
        priority: 'high',
      ),
      EnquiryModel(
        id: 4,
        ref: 'ENQ-455',
        client: 'GMR Airports',
        scope: 'Airport Lounge Expansion MEP',
        value: '~₹2.4 Cr',
        source: EnquirySource.direct,
        received: now.subtract(const Duration(days: 2)),
        status: EnquiryStatus.quoted,
        priority: 'medium',
      ),
    ]);

    // 6. Reminders
    _reminders.addAll([
      ReminderModel(
        id: 1,
        title: 'Call Voltas — AHU delivery update',
        time: DateTime(now.year, now.month, now.day, 10, 0),
        type: 'call',
        priority: 'high',
        repeat: 'none',
        isDone: false,
      ),
      ReminderModel(
        id: 2,
        title: 'Send weekly SLA report to Director',
        time: DateTime(now.year, now.month, now.day, 11, 30),
        type: 'report',
        priority: 'medium',
        repeat: 'weekly',
        isDone: false,
      ),
      ReminderModel(
        id: 3,
        title: 'PO approval deadline — Daikin India',
        time: DateTime(now.year, now.month, now.day, 14, 0),
        type: 'approval',
        priority: 'high',
        repeat: 'none',
        isDone: false,
      ),
      ReminderModel(
        id: 4,
        title: 'Site visit — Sunrise Mall Block A',
        time: DateTime(now.year, now.month, now.day + 1, 9, 0),
        type: 'visit',
        priority: 'medium',
        repeat: 'none',
        isDone: false,
      ),
      ReminderModel(
        id: 5,
        title: 'Review Metro Station progress %',
        time: DateTime(now.year, now.month, now.day + 1, 16, 0),
        type: 'task',
        priority: 'low',
        repeat: 'none',
        isDone: false,
      ),
      ReminderModel(
        id: 6,
        title: 'Monthly vendor rating update',
        time: DateTime(now.year, now.month, now.day + 2, 10, 0),
        type: 'task',
        priority: 'low',
        repeat: 'monthly',
        isDone: false,
      ),
    ]);

    // 7. Activity Feed
    _activityFeed.addAll([
      FeedActivityModel(
        id: 'act_1',
        iconEmoji: '✅',
        text: 'PO-2024-089 approved — ₹18.5L Daikin',
        timestamp: now.subtract(const Duration(minutes: 8)),
        colorTag: 'success',
      ),
      FeedActivityModel(
        id: 'act_2',
        iconEmoji: '🚨',
        text: 'SLA BREACH — Copper Pipes 5 days overdue',
        timestamp: now.subtract(const Duration(minutes: 22)),
        colorTag: 'danger',
      ),
      FeedActivityModel(
        id: 'act_3',
        iconEmoji: '📥',
        text: 'New enquiry — Greenfield Developers (WhatsApp)',
        timestamp: now.subtract(const Duration(hours: 2)),
        colorTag: 'primary',
      ),
      FeedActivityModel(
        id: 'act_4',
        iconEmoji: '⚠️',
        text: 'City Hospital timeline revised — 2 week delay',
        timestamp: now.subtract(const Duration(hours: 3)),
        colorTag: 'warning',
      ),
      FeedActivityModel(
        id: 'act_5',
        iconEmoji: '✅',
        text: 'Luxe Residences 95% — handover checklist started',
        timestamp: now.subtract(const Duration(hours: 5)),
        colorTag: 'success',
      ),
    ]);
  }

  // --- Live Simulation ---
  static const List<Map<String, String>> _feedPool = [
    {'icon': '📦', 'text': 'PO-2024-092 Voltas — delivery confirmed at Airport T3', 'color': 'primary'},
    {'icon': '✅', 'text': 'SLA resolved: Fire Dampers Pharma Plant closed by Suresh I', 'color': 'success'},
    {'icon': '📞', 'text': 'Follow-up logged: Greenfield Dev — HVAC quote sent', 'color': 'info'},
    {'icon': '⚡', 'text': 'Approval pending: PO-2024-097 Daikin ₹14.2L — 1 day old', 'color': 'warning'},
    {'icon': '📊', 'text': 'Airport T3 crossed 65% milestone — on track', 'color': 'success'},
    {'icon': '💬', 'text': 'WhatsApp: DLF Infra — site visit confirmed tomorrow 10 AM', 'color': 'primary'},
    {'icon': '🔔', 'text': 'Reminder: ENQ-455 GMR Airports follow-up due today', 'color': 'warning'},
  ];

  void _startLiveSimulation() {
    // 1. KPI Tick (every 3.5s)
    _kpiTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      _kpiTasks = (_kpiTasks + (_rng.nextInt(3) - 1)).clamp(8, 18);
      _kpiBreaches = (_kpiBreaches + (_rng.nextInt(3) - 1)).clamp(1, 6);
      _kpiApprovals = (_kpiApprovals + (_rng.nextInt(3) - 1)).clamp(2, 7);
      _kpiEnquiries = (_kpiEnquiries + (_rng.nextInt(3) - 1)).clamp(4, 12);
      notifyListeners();
    });

    // 2. Project Tick (every 5s)
    _projectTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_projects.isNotEmpty) {
        final idx = _rng.nextInt(_projects.length);
        final current = _projects[idx];
        if (current.pct < 99) {
          final newPct = (current.pct + 1).clamp(0.0, 99.0);
          _projects[idx] = current.copyWith(pct: newPct);
          notifyListeners();
        }
      }
    });

    // 3. Activity Feed (every 7s)
    _feedTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      final sample = _feedPool[_rng.nextInt(_feedPool.length)];
      _activityFeed.insert(
        0,
        FeedActivityModel(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}',
          iconEmoji: sample['icon']!,
          text: sample['text']!,
          timestamp: DateTime.now(),
          colorTag: sample['color']!,
          isNew: true,
        ),
      );
      if (_activityFeed.length > 20) {
        _activityFeed.removeLast();
      }
      notifyListeners();
    });

    // 4. Background Simulated Live Notification (every 22s)
    _notifTimer = Timer.periodic(const Duration(seconds: 22), (_) {
      final notifs = [
        ('SLA Breach Update', 'Fire Dampers Pharma Plant — now 13h overdue', NotificationType.alert),
        ('Approval Needed Urgently', 'PO-2024-096 Grundfos ₹12L — pending 1 day', NotificationType.warning),
        ('WhatsApp Enquiry', 'New message from DLF Infra — HVAC scope query', NotificationType.info),
        ('Project Milestone Hit', 'Airport Terminal T3 crossed 65% — on track', NotificationType.success),
        ('SLA Resolved', 'ENQ-447 closed — Green Valley converted to project', NotificationType.success),
      ];
      final item = notifs[_rng.nextInt(notifs.length)];
      NotificationService().pushNotification(
        title: item.$1,
        message: item.$2,
        type: item.$3,
      );
    });
  }

  /// Cancels all background simulation timers.
  void stopSimulation() {
    _kpiTimer?.cancel();
    _projectTimer?.cancel();
    _feedTimer?.cancel();
    _notifTimer?.cancel();
    _kpiTimer = null;
    _projectTimer = null;
    _feedTimer = null;
    _notifTimer = null;
  }

  /// Synchronizes state with local MySQL database via ApiService
  Future<void> syncFromMySqlBackend() async {
    try {
      final isConnected = await ApiService.instance.checkHealth();
      if (!isConnected) return;

      // 1. Projects
      final apiProjects = await ApiService.instance.fetchProjects();
      if (apiProjects != null && apiProjects.isNotEmpty) {
        _projects.clear();
        _projects.addAll(apiProjects);
      }

      // 2. Tasks
      final apiTasks = await ApiService.instance.fetchTasks();
      if (apiTasks != null && apiTasks.isNotEmpty) {
        _myTasks.clear();
        _myTasks.addAll(apiTasks);
      }

      // 3. Follow-ups
      final apiFollowUps = await ApiService.instance.fetchFollowUps();
      if (apiFollowUps != null && apiFollowUps.isNotEmpty) {
        _followUps.clear();
        _followUps.addAll(apiFollowUps);
      }

      // 4. Approvals
      final apiApprovals = await ApiService.instance.fetchApprovals();
      if (apiApprovals != null && apiApprovals.isNotEmpty) {
        _approvals.clear();
        _approvals.addAll(apiApprovals);
      }

      // 5. Enquiries
      final apiEnquiries = await ApiService.instance.fetchEnquiries();
      if (apiEnquiries != null && apiEnquiries.isNotEmpty) {
        _enquiries.clear();
        _enquiries.addAll(apiEnquiries);
      }

      // 6. Reminders
      final apiReminders = await ApiService.instance.fetchReminders();
      if (apiReminders != null && apiReminders.isNotEmpty) {
        _reminders.clear();
        _reminders.addAll(apiReminders);
      }

      // 7. Activity Logs
      final apiLogs = await ApiService.instance.fetchActivityLogs();
      if (apiLogs != null && apiLogs.isNotEmpty) {
        for (final log in apiLogs.reversed) {
          if (!_activityFeed.any((a) => a.id == log.id)) {
            _activityFeed.insert(0, log);
          }
        }
      }

      // Update KPI counters based on real database entries
      _kpiTasks = _myTasks.where((t) => !t.isDone).length;
      _kpiApprovals = _approvals.where((a) => a.status == ApprovalStatus.pending).length;
      _kpiEnquiries = _enquiries.length;
      _kpiBreaches = _followUps.where((f) => f.status == FollowUpStatus.overdue).length;

      notifyListeners();
    } catch (e) {
      debugPrint('[KelvinOpsService] syncFromMySqlBackend error: $e');
    }
  }

  // --- Mutations ---
  void toggleTask(int id) {
    final idx = _myTasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _myTasks[idx] = _myTasks[idx].copyWith(isDone: !_myTasks[idx].isDone);
      notifyListeners();
      ApiService.instance.toggleTask(id);
    }
  }

  void markFollowUpDone(int id) {
    _followUps.removeWhere((f) => f.id == id);
    notifyListeners();
    ApiService.instance.deleteFollowUp(id);
  }

  void snoozeFollowUp(int id, Duration duration) {
    final idx = _followUps.indexWhere((f) => f.id == id);
    if (idx != -1) {
      final f = _followUps[idx];
      _followUps[idx] = f.copyWith(
        status: FollowUpStatus.upcoming,
        due: f.due.add(duration),
      );
      notifyListeners();
      ApiService.instance.snoozeFollowUp(id, hours: duration.inHours);
    }
  }

  void approvePO(int id, {String? note}) {
    final idx = _approvals.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final approvedItem = _approvals[idx];
      _approvals.removeAt(idx);
      _activityFeed.insert(
        0,
        FeedActivityModel(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}',
          iconEmoji: '✅',
          text: '${approvedItem.po} approved (${approvedItem.amount} ${approvedItem.vendor})',
          timestamp: DateTime.now(),
          colorTag: 'success',
          isNew: true,
        ),
      );
      notifyListeners();
      ApiService.instance.approvePO(id, note: note);
    }
  }

  void rejectPO(int id) {
    final idx = _approvals.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final rejected = _approvals[idx];
      _approvals.removeAt(idx);
      _activityFeed.insert(
        0,
        FeedActivityModel(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}',
          iconEmoji: '❌',
          text: '${rejected.po} rejected (${rejected.amount} ${rejected.vendor})',
          timestamp: DateTime.now(),
          colorTag: 'danger',
          isNew: true,
        ),
      );
      notifyListeners();
      ApiService.instance.rejectPO(id);
    }
  }

  void assignEnquiry(int id, String person) {
    final idx = _enquiries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _enquiries[idx] = _enquiries[idx].copyWith(assignedTo: person);
      notifyListeners();
      ApiService.instance.assignEnquiry(id, person);
    }
  }

  void convertEnquiryToFollowUp(int id) {
    final idx = _enquiries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final enq = _enquiries[idx];
      _followUps.insert(
        0,
        FollowUpModel(
          id: DateTime.now().millisecondsSinceEpoch,
          contact: enq.client,
          company: enq.client,
          topic: enq.scope,
          phone: '+91 98000 00000',
          project: enq.scope,
          due: DateTime.now().add(const Duration(days: 1)),
          status: FollowUpStatus.upcoming,
          channel: ContactChannel.whatsapp,
        ),
      );
      notifyListeners();
    }
  }

  void addReminder(ReminderModel r) {
    _reminders.insert(0, r);
    notifyListeners();
    ApiService.instance.createReminder(r);
  }

  void toggleReminder(int id) {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reminders[idx] = _reminders[idx].copyWith(isDone: !_reminders[idx].isDone);
      notifyListeners();
      ApiService.instance.toggleReminder(id);
    }
  }

  void deleteReminder(int id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _kpiTimer?.cancel();
    _projectTimer?.cancel();
    _feedTimer?.cancel();
    _notifTimer?.cancel();
    super.dispose();
  }
}
