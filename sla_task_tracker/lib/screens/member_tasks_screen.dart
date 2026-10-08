import 'package:flutter/material.dart';
import '../services/data_store.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';

class MemberTasksScreen extends StatefulWidget {
  final String memberId;
  const MemberTasksScreen({super.key, required this.memberId});

  @override
  State<MemberTasksScreen> createState() => _MemberTasksScreenState();
}

class _MemberTasksScreenState extends State<MemberTasksScreen> {
  Future<void> _openTask(String taskId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: taskId)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    final member = store.memberById(widget.memberId);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team Member')),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Member not found',
          message: 'This profile may no longer be available.',
        ),
      );
    }

    final tasks = store.tasksForMember(member.id);
    final compliance = (store.slaComplianceFor(member.id) * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                InitialsAvatar(member: member, size: 52, showStatusDot: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.role,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(member.team,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$compliance%',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const Text('SLA compliance',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Assigned tasks (${tasks.length})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
          ),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No tasks assigned',
              message: 'Tasks assigned to this member will appear here.',
            )
          else
            ...tasks.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskCard(
                  task: t,
                  assignee: member,
                  onTap: () => _openTask(t.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
