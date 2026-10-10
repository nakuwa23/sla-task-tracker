import '../models/activity_log_entry.dart';
import '../models/sla_status.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/team_member.dart';
import 'seed_data.dart';
import 'sla_calculator.dart';
import 'storage_service.dart';

class DataStore {
  DataStore._internal();
  static final DataStore instance = DataStore._internal();

  final StorageService _storage = StorageService();

  List<TeamMember> members = [];
  List<Task> tasks = [];
  List<ActivityLogEntry> activityLog = [];
  TeamMember? currentUser;
  bool rememberMe = false;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Loads everything from local storage, seeding demo data on first run.
  /// Also restores the signed-in user if "Remember me" was set previously.
  Future<void> init() async {
    if (_initialized) return;

    members = await _storage.loadMembers();
    final uniqueMembers = _uniqueMembers(members);
    if (uniqueMembers.length != members.length) {
      members = uniqueMembers;
      await _storage.saveMembers(members);
    }
    if (members.isEmpty) {
      members = SeedData.members();
      await _storage.saveMembers(members);
    }

    tasks = await _storage.loadTasks();
    if (tasks.isEmpty) {
      tasks = SeedData.tasks();
      await _storage.saveTasks(tasks);
    }

    activityLog = await _storage.loadActivity();
    if (activityLog.isEmpty) {
      activityLog = SeedData.activity();
      await _storage.saveActivity(activityLog);
    }

    rememberMe = await _storage.loadRememberMe();
    final savedId = await _storage.loadCurrentUserId();
    if (rememberMe && savedId != null) {
      currentUser = memberById(savedId);
    }

    _initialized = true;
  }

  Future<void> signIn(TeamMember member, {required bool remember}) async {
    currentUser = member;
    rememberMe = remember;
    await _storage.saveRememberMe(remember);
    await _storage.saveCurrentUserId(remember ? member.id : null);
  }

  Future<void> signOut() async {
    currentUser = null;
    await _storage.saveCurrentUserId(null);
  }

  /// Reuses a stored profile for an existing email, or creates one for a
  /// first-time local sign-in and makes it available on the next selection.
  Future<TeamMember> findOrCreateMember(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = members.cast<TeamMember?>().firstWhere(
          (member) => member!.email.trim().toLowerCase() == normalizedEmail,
          orElse: () => null,
        );
    if (existing != null) return existing;

    final member = TeamMember(
      id: 'member-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameFromEmail(email),
      email: email.trim(),
      role: 'Team member',
      team: 'My team',
      location: 'Not specified',
      avatarColorValue: 0xFF8AA4D6,
    );
    members = [...members, member];
    await _storage.saveMembers(members);
    return member;
  }

  List<TeamMember> _uniqueMembers(List<TeamMember> source) {
    final seenEmails = <String>{};
    return source.where((member) {
      final email = member.email.trim().toLowerCase();
      return seenEmails.add(email);
    }).toList();
  }

  String _nameFromEmail(String email) {
    final localPart = email.trim().split('@').first;
    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  TeamMember? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  // Task CRUD
  String _nextTaskId() {
    var maxN = 100;
    final pattern = RegExp(r'^T-(\d+)$');
    for (final t in tasks) {
      final match = pattern.firstMatch(t.id);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > maxN) maxN = n;
      }
    }
    return 'T-${maxN + 1}';
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required String category,
    required DateTime startDate,
    required DateTime dueDate,
    required TaskPriority priority,
    required String assigneeId,
  }) async {
    final task = Task(
      id: _nextTaskId(),
      title: title.trim(),
      description: description.trim(),
      category: category.trim().isEmpty ? 'General' : category.trim(),
      startDate: startDate,
      dueDate: dueDate,
      priority: priority,
      assigneeId: assigneeId,
      createdAt: DateTime.now(),
    );
    tasks = [task, ...tasks];
    await _storage.saveTasks(tasks);
    await _logActivity('created task "${task.title}" (${task.id}).');
    return task;
  }

  Future<void> updateTask(Task updated) async {
    tasks = [
      for (final t in tasks)
        if (t.id == updated.id) updated else t,
    ];
    await _storage.saveTasks(tasks);
    await _logActivity('updated task "${updated.title}" (${updated.id}).');
  }

  Future<void> deleteTask(String id) async {
    final removed = tasks.where((t) => t.id == id).toList();
    tasks = tasks.where((t) => t.id != id).toList();
    await _storage.saveTasks(tasks);
    if (removed.isNotEmpty) {
      await _logActivity('deleted task "${removed.first.title}" ($id).');
    }
  }

  Future<void> setTaskCompleted(String id, bool completed) async {
    final updatedTasks = <Task>[];
    Task? changed;

    for (final t in tasks) {
      if (t.id == id) {
        final newTask = t.copyWith(
          isCompleted: completed,
          completedAt: completed ? DateTime.now() : null,
          clearCompletedAt: !completed,
        );
        changed = newTask;
        updatedTasks.add(newTask);
      } else {
        updatedTasks.add(t);
      }
    }

    tasks = updatedTasks;
    await _storage.saveTasks(tasks);

    if (changed != null) {
      final title = changed.title;
      await _logActivity(
        completed ? 'marked "$title" as completed.' : 'reopened "$title".',
      );
    }
  }

  // Activity log
  Future<void> _logActivity(String message) async {
    final entry = ActivityLogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      actorName: currentUser?.name ?? 'System',
      message: message,
      timestamp: DateTime.now(),
    );
    activityLog = [entry, ...activityLog];
    if (activityLog.length > 60) {
      activityLog = activityLog.sublist(0, 60);
    }
    await _storage.saveActivity(activityLog);
  }

  // Derived / computed stats — always calculated from `tasks`, never
  // hardcoded. Every screen that shows a count calls one of these.
  List<Task> tasksFor(SlaStatus status) =>
      tasks.where((t) => SlaCalculator.statusFor(t) == status).toList();

  List<Task> tasksForMember(String memberId) =>
      tasks.where((t) => t.assigneeId == memberId).toList();

  int get activeTasksCount => tasks.where((t) => !t.isCompleted).length;
  int get onTrackCount => tasksFor(SlaStatus.onTrack).length;
  int get atRiskCount => tasksFor(SlaStatus.atRisk).length;
  int get overdueCount => tasksFor(SlaStatus.overdue).length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get totalCount => tasks.length;

  /// 0..1 fraction of all tasks that are completed — drives the dashboard
  /// progress summary.
  double get overallProgress {
    if (tasks.isEmpty) return 0;
    return completedCount / totalCount;
  }

  double slaComplianceFor(String memberId) {
    final assigned = tasksForMember(memberId);
    if (assigned.isEmpty) return 1.0;
    final nonOverdue = assigned
        .where((t) => SlaCalculator.statusFor(t) != SlaStatus.overdue)
        .length;
    return nonOverdue / assigned.length;
  }

  int completedCountFor(String memberId) =>
      tasksForMember(memberId).where((t) => t.isCompleted).length;

  int activeCountFor(String memberId) =>
      tasksForMember(memberId).where((t) => !t.isCompleted).length;
}
