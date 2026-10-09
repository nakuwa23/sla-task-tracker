import 'package:flutter/material.dart';
import '../models/sla_status.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';
import '../services/sla_calculator.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/priority_badge.dart';
import '../widgets/sla_badge.dart';
import 'task_form_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _busy = false;

  Task? get _task {
    final matches = DataStore.instance.tasks.where((t) => t.id == widget.taskId);
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _toggleComplete(Task task) async {
    setState(() => _busy = true);
    try {
      await DataStore.instance.setTaskCompleted(task.id, !task.isCompleted);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the task. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editTask(Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(existingTask: task)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete task?',
      message: 'This will permanently remove "${task.title}". This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      await DataStore.instance.deleteTask(task.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the task. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Task not found',
          message: 'This task may have been deleted.',
        ),
      );
    }

    final store = DataStore.instance;
    final assignee = store.memberById(task.assigneeId);
    final status = SlaCalculator.statusFor(task);
    final remaining = SlaCalculator.timeRemaining(task);
    final relatedActivity = store.activityLog
        .where((e) => e.message.contains(task.id))
        .take(3)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'edit') _editTask(task);
              if (value == 'delete') _deleteTask(task);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit task')),
              PopupMenuItem(value: 'delete', child: Text('Delete task')),
            ],
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SlaBadge(status: status),
                          const Spacer(),
                          Text(
                            task.id,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledValue(
                              label: 'DUE DATE',
                              icon: Icons.calendar_today_outlined,
                              value: AppDateUtils.formatDate(task.dueDate),
                            ),
                          ),
                          Expanded(
                            child: _LabeledValue(
                              label: 'PRIORITY',
                              icon: Icons.flag_outlined,
                              valueWidget: PriorityBadge(priority: task.priority),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledValue(
                              label: 'LEAD ASSIGNEE',
                              icon: Icons.person_outline_rounded,
                              value: assignee?.name ?? 'Unassigned',
                            ),
                          ),
                          Expanded(
                            child: _LabeledValue(
                              label: 'TEAM',
                              icon: Icons.groups_outlined,
                              value: assignee?.team ?? '—',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!task.isCompleted) _SlaTimerCard(task: task, status: status, remaining: remaining),
                if (task.isCompleted)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.completedBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.completed.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.completed),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.completedAt != null
                                ? 'Completed on ${AppDateUtils.formatDate(task.completedAt!)}'
                                : 'Completed',
                            style: const TextStyle(
                              color: AppColors.completed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                const Text('Description',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  task.description.isEmpty ? 'No description provided.' : task.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Activity Log',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    if (store.activityLog.length > relatedActivity.length)
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('See full history on the Overview tab.'),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (relatedActivity.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No activity recorded for this task yet.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  )
                else
                  ...relatedActivity.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InitialsAvatar(
                              member: _findMemberByName(store, entry.actorName),
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.actorName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.message,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary, fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AppDateUtils.timeAgo(entry.timestamp),
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: _busy
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comments aren\'t available in this demo.')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleComplete(task),
                        icon: Icon(
                          task.isCompleted
                              ? Icons.replay_rounded
                              : Icons.check_rounded,
                          size: 18,
                        ),
                        label: Text(task.isCompleted ? 'Reopen Task' : 'Mark as complete'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

TeamMember? _findMemberByName(DataStore store, String name) {
  for (final m in store.members) {
    if (m.name == name) return m;
  }
  return null;
}

class _LabeledValue extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final Widget? valueWidget;

  const _LabeledValue({
    required this.label,
    required this.icon,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        valueWidget ??
            Row(
              children: [
                Icon(icon, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    value ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                ),
              ],
            ),
      ],
    );
  }
}

class _SlaTimerCard extends StatelessWidget {
  final Task task;
  final SlaStatus status;
  final Duration remaining;

  const _SlaTimerCard({required this.task, required this.status, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isOverdue = status == SlaStatus.overdue;
    final color = isOverdue
        ? AppColors.overdue
        : (status == SlaStatus.atRisk ? AppColors.atRisk : AppColors.onTrack);
    final bg = isOverdue
        ? AppColors.overdueBg
        : (status == SlaStatus.atRisk ? AppColors.atRiskBg : AppColors.onTrackBg);

    final windowMinutes = task.priority.responseWindow.inMinutes;
    final remainingMinutes = remaining.inMinutes;
    final progress = windowMinutes <= 0
        ? 1.0
        : (1 - (remainingMinutes / (windowMinutes * 3))).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverdue ? 'Overdue by' : 'SLA time remaining',
                style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13.5),
              ),
              Text(
                AppDateUtils.formatDuration(remaining),
                style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: isOverdue ? 1.0 : progress.toDouble(),
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOverdue
                ? 'This task passed its due date. Complete it or update the deadline.'
                : 'Flips to "At Risk" inside ${task.priority.responseLabel} of the deadline.',
            style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
