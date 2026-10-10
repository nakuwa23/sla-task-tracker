import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_log_entry.dart';
import '../models/task.dart';
import '../models/team_member.dart';

class StorageService {
  static const _tasksKey = 'sla_tracker.tasks.v1';
  static const _membersKey = 'sla_tracker.members.v1';
  static const _activityKey = 'sla_tracker.activity.v1';
  static const _currentUserKey = 'sla_tracker.currentUserId.v1';
  static const _rememberMeKey = 'sla_tracker.rememberMe.v1';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted or incompatible data on disk — fail safe to an empty list
      // instead of crashing the app on launch.
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, raw);
  }

  Future<List<TeamMember>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_membersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMembers(List<TeamMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_membersKey, raw);
  }

  Future<List<ActivityLogEntry>> loadActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activityKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ActivityLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActivity(List<ActivityLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_activityKey, raw);
  }

  Future<String?> loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> saveCurrentUserId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, id);
    }
  }

  Future<bool> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }
}
