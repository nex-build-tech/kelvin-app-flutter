import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/approval_model.dart';
import '../../models/enquiry_model.dart';
import '../../models/feed_activity_model.dart';
import '../../models/follow_up_model.dart';
import '../../models/hvac_project_model.dart';
import '../../models/hvac_task_model.dart';
import '../../models/reminder_model.dart';
import '../../models/user_model.dart';

/// Central API Service for Kelvin Mech Mobile App.
/// Handles HTTP communication with the local Express / MySQL 8.0 backend.
/// Automatically detects platform (Android emulator vs Desktop/Web) and supports
/// custom host configuration for physical Wi-Fi devices.
class ApiService extends ChangeNotifier {
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;

  ApiService._internal() {
    _loadCustomBaseUrl();
  }

  // --- Base URL Resolution ---
  static const String _defaultLocalhost = 'http://localhost:5000/api';
  static const String _defaultAndroidEmulator = 'http://10.0.2.2:5000/api';

  String _baseUrl = _resolveDefaultBaseUrl();
  bool _isBackendConnected = false;
  DateTime? _lastSyncTime;

  String get baseUrl => _baseUrl;
  bool get isBackendConnected => _isBackendConnected;
  DateTime? get lastSyncTime => _lastSyncTime;

  static String _resolveDefaultBaseUrl() {
    if (kIsWeb) return _defaultLocalhost;
    try {
      if (Platform.isAndroid) {
        return _defaultAndroidEmulator;
      }
    } catch (_) {
      // Fallback for non-standard environments
    }
    return _defaultLocalhost;
  }

  Future<void> _loadCustomBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('api_base_url');
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        _baseUrl = savedUrl.trim();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setCustomBaseUrl(String url) async {
    _baseUrl = url.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_base_url', _baseUrl);
    } catch (_) {}
    notifyListeners();
    await checkHealth();
  }

  Uri _uri(String endpoint) => Uri.parse('$_baseUrl$endpoint');

  // --- Health Check ---
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(_uri('/health'))
          .timeout(const Duration(milliseconds: 2500));
      if (response.statusCode == 200) {
        _isBackendConnected = true;
        _lastSyncTime = DateTime.now();
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Backend offline or unreachable
    }
    _isBackendConnected = false;
    notifyListeners();
    return false;
  }

  // --- 1. Authentication ---
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            _uri('/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'];
        _isBackendConnected = true;
        _lastSyncTime = DateTime.now();
        notifyListeners();
        return UserModel(
          id: userJson['id'].toString(),
          name: userJson['name'] ?? '',
          email: userJson['email'] ?? '',
          role: userJson['role'] ?? '',
          phone: userJson['phone'] ?? '',
          department: userJson['department'] ?? '',
        );
      }
    } catch (e) {
      debugPrint('[ApiService] login error: $e');
    }
    return null;
  }

  // --- 2. Projects ---
  Future<List<HvacProjectModel>?> fetchProjects() async {
    try {
      final response = await http
          .get(_uri('/projects'))
          .timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isBackendConnected = true;
        _lastSyncTime = DateTime.now();
        return list.map((item) {
          final statusStr = item['status'] as String? ?? 'onTrack';
          ProjectStatus status = ProjectStatus.onTrack;
          if (statusStr == 'delayed' || statusStr == 'critical') {
            status = ProjectStatus.delayed;
          } else if (statusStr == 'atRisk') {
            status = ProjectStatus.atRisk;
          }

          final pctVal = double.tryParse(item['completion_pct']?.toString() ?? '0') ?? 0.0;

          return HvacProjectModel(
            id: item['id'] as int,
            name: item['name'] as String? ?? '',
            pct: pctVal,
            status: status,
            phase: item['phase'] as String? ?? 'Execution',
            value: item['contract_value'] as String? ?? '₹0 Cr',
            client: item['client_name'] as String? ?? 'Client',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] fetchProjects error: $e');
    }
    return null;
  }

  // --- 3. Tasks ---
  Future<List<HvacTaskModel>?> fetchTasks() async {
    try {
      final response = await http
          .get(_uri('/tasks'))
          .timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isBackendConnected = true;
        return list.map((item) {
          return HvacTaskModel(
            id: item['id'] as int,
            title: item['title'] as String? ?? '',
            project: item['project_name'] as String? ?? '',
            due: item['due_date'] != null
                ? DateTime.tryParse(item['due_date'].toString()) ?? DateTime.now()
                : DateTime.now(),
            priority: item['priority'] as String? ?? 'low',
            isDone: item['is_done'] == 1 || item['is_done'] == true,
            type: item['task_type'] as String? ?? 'task',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] fetchTasks error: $e');
    }
    return null;
  }

  Future<bool> toggleTask(int id) async {
    try {
      final response = await http
          .patch(_uri('/tasks/$id/toggle'))
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] toggleTask error: $e');
      return false;
    }
  }

  // --- 4. Follow-ups ---
  Future<List<FollowUpModel>?> fetchFollowUps() async {
    try {
      final response = await http
          .get(_uri('/followups'))
          .timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isBackendConnected = true;
        return list.map((item) {
          final sStr = item['status'] as String? ?? 'upcoming';
          FollowUpStatus status = FollowUpStatus.upcoming;
          if (sStr == 'overdue') status = FollowUpStatus.overdue;
          if (sStr == 'dueToday') status = FollowUpStatus.dueToday;

          final cStr = item['channel'] as String? ?? 'call';
          ContactChannel channel = ContactChannel.call;
          if (cStr == 'whatsapp') channel = ContactChannel.whatsapp;
          if (cStr == 'email') channel = ContactChannel.email;

          return FollowUpModel(
            id: item['id'] as int,
            contact: item['contact_name'] as String? ?? '',
            company: item['company'] as String? ?? '',
            topic: item['topic'] as String? ?? '',
            phone: item['phone'] as String? ?? '',
            project: item['project_name'] as String? ?? '',
            due: item['due_date'] != null
                ? DateTime.tryParse(item['due_date'].toString()) ?? DateTime.now()
                : DateTime.now(),
            status: status,
            channel: channel,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] fetchFollowUps error: $e');
    }
    return null;
  }

  Future<bool> deleteFollowUp(int id) async {
    try {
      final response = await http
          .delete(_uri('/followups/$id'))
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] deleteFollowUp error: $e');
      return false;
    }
  }

  Future<bool> snoozeFollowUp(int id, {int hours = 24}) async {
    try {
      final response = await http
          .patch(
            _uri('/followups/$id/snooze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'hours': hours}),
          )
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] snoozeFollowUp error: $e');
      return false;
    }
  }

  // --- 5. PO Approvals ---
  Future<List<ApprovalModel>?> fetchApprovals() async {
    try {
      final response = await http
          .get(_uri('/approvals'))
          .timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isBackendConnected = true;
        return list.map((item) {
          final uStr = item['urgency'] as String? ?? 'medium';
          ApprovalUrgency urgency = ApprovalUrgency.medium;
          if (uStr == 'high') urgency = ApprovalUrgency.high;
          if (uStr == 'low') urgency = ApprovalUrgency.low;

          final stStr = item['status'] as String? ?? 'pending';
          ApprovalStatus status = ApprovalStatus.pending;
          if (stStr == 'approved') status = ApprovalStatus.approved;
          if (stStr == 'rejected') status = ApprovalStatus.rejected;

          final lakh = double.tryParse(item['amount_lakhs']?.toString() ?? '0') ?? 0.0;

          return ApprovalModel(
            id: item['id'] as int,
            po: item['po_number'] as String? ?? '',
            vendor: item['vendor_name'] as String? ?? '',
            item: item['item_description'] as String? ?? '',
            amount: item['amount_display'] as String? ?? '₹0',
            amountInLakhs: lakh,
            days: item['days_pending'] as int? ?? 1,
            urgency: urgency,
            status: status,
            requestedBy: item['requested_by'] as String? ?? '',
            note: item['signoff_note'] as String?,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] fetchApprovals error: $e');
    }
    return null;
  }

  Future<bool> approvePO(int id, {String? note}) async {
    try {
      final response = await http
          .post(
            _uri('/approvals/$id/approve'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'note': note ?? 'Approved via Kelvin Mech Mobile App'}),
          )
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] approvePO error: $e');
      return false;
    }
  }

  Future<bool> rejectPO(int id, {String? note}) async {
    try {
      final response = await http
          .post(
            _uri('/approvals/$id/reject'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'note': note ?? 'Rejected via Kelvin Mech Mobile App'}),
          )
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] rejectPO error: $e');
      return false;
    }
  }

  // --- 6. Enquiries ---
  Future<List<EnquiryModel>?> fetchEnquiries() async {
    try {
      final response = await http
          .get(_uri('/enquiries'))
          .timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isBackendConnected = true;
        return list.map((item) {
          final srcStr = item['source'] as String? ?? 'whatsapp';
          EnquirySource source = EnquirySource.whatsapp;
          if (srcStr == 'email') source = EnquirySource.email;
          if (srcStr == 'referral') source = EnquirySource.referral;
          if (srcStr == 'direct') source = EnquirySource.direct;

          final stStr = item['status'] as String? ?? 'newLead';
          EnquiryStatus status = EnquiryStatus.newLead;
          if (stStr == 'contacted') status = EnquiryStatus.contacted;
          if (stStr == 'siteVisit') status = EnquiryStatus.siteVisit;
          if (stStr == 'quoted') status = EnquiryStatus.quoted;

          return EnquiryModel(
            id: item['id'] as int,
            ref: item['ref_code'] as String? ?? '',
            client: item['client_name'] as String? ?? '',
            scope: item['scope_description'] as String? ?? '',
            value: item['estimated_value'] as String? ?? '',
            source: source,
            received: item['received_at'] != null
                ? DateTime.tryParse(item['received_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
            status: status,
            priority: item['priority'] as String? ?? 'medium',
            assignedTo: item['assigned_to'] as String?,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] fetchEnquiries error: $e');
    }
    return null;
  }

  Future<bool> assignEnquiry(int id, String person) async {
    try {
      final response = await http
          .patch(
            _uri('/enquiries/$id/assign'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'assigned_to': person}),
          )
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] assignEnquiry error: $e');
      return false;
    }
  }

  // --- 7. Reminders ---
  Future<List<ReminderModel>?> fetchReminders() async {
    try {
      final response = await http
          .get(_uri('/reminders'))
          .timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isBackendConnected = true;
        return list.map((item) {
          return ReminderModel(
            id: item['id'] as int,
            title: item['title'] as String? ?? '',
            time: item['scheduled_time'] != null
                ? DateTime.tryParse(item['scheduled_time'].toString()) ?? DateTime.now()
                : DateTime.now(),
            type: item['reminder_type'] as String? ?? 'task',
            priority: item['priority'] as String? ?? 'medium',
            repeat: item['repeat_frequency'] as String? ?? 'none',
            isDone: item['is_done'] == 1 || item['is_done'] == true,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] fetchReminders error: $e');
    }
    return null;
  }

  Future<bool> createReminder(ReminderModel r) async {
    try {
      final response = await http
          .post(
            _uri('/reminders'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'title': r.title,
              'scheduled_time': r.time.toIso8601String(),
              'reminder_type': r.type,
              'priority': r.priority,
              'repeat_frequency': r.repeat,
            }),
          )
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('[ApiService] createReminder error: $e');
      return false;
    }
  }

  Future<bool> toggleReminder(int id) async {
    try {
      final response = await http
          .patch(_uri('/reminders/$id/toggle'))
          .timeout(const Duration(milliseconds: 3000));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] toggleReminder error: $e');
      return false;
    }
  }

  // --- 8. Activity Logs ---
  Future<List<FeedActivityModel>?> fetchActivityLogs() async {
    try {
      final response = await http
          .get(_uri('/activity'))
          .timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isBackendConnected = true;
        return list.map((item) {
          return FeedActivityModel(
            id: 'act_${item['id']}',
            iconEmoji: item['icon_emoji'] as String? ?? '📌',
            text: item['activity_text'] as String? ?? '',
            timestamp: item['created_at'] != null
                ? DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
            colorTag: item['color_tag'] as String? ?? 'primary',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] fetchActivityLogs error: $e');
    }
    return null;
  }
}
