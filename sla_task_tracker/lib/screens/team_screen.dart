import 'package:flutter/material.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_header.dart';
import 'member_tasks_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  void _notAvailable(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what isn\'t available in this offline demo.')),
    );
  }

  Future<void> _openMember(TeamMember member) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberTasksScreen(memberId: member.id)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    final current = store.currentUser;
    final others = store.members.where((m) => m.id != current?.id).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Team Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () => _notAvailable('Adding team members'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${current?.team ?? 'Team'} · ${store.members.length} members',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (current != null) _CurrentUserCard(member: current, onAction: _notAvailable),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Team Directory'),
          const SizedBox(height: 10),
          if (others.isEmpty)
            const EmptyState(
              icon: Icons.groups_outlined,
              title: 'No other team members',
              message: 'Everyone else on the roster will appear here.',
            )
          else
            ...others.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MemberTile(member: m, onTap: () => _openMember(m)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentUserCard extends StatelessWidget {
  final TeamMember member;
  final void Function(String) onAction;
  const _CurrentUserCard({required this.member, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    final completed = store.completedCountFor(member.id);
    final active = store.activeCountFor(member.id);
    final totalAssigned = completed + active;
    final compliance = (store.slaComplianceFor(member.id) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              InitialsAvatar(member: member, size: 56, showStatusDot: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(member.role,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          '${member.location} · ${member.isAvailable ? 'Available' : 'Away'}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Performance Summary',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Tasks completed',
                      value: '$completed',
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.schedule_rounded,
                      label: 'SLA compliance',
                      value: '$compliance%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Current workload',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  Text(
                    '$active of $totalAssigned tasks',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalAssigned == 0 ? 0 : active / totalAssigned,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.onTrack),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onAction('Email'),
                icon: const Icon(Icons.mail_outline_rounded, size: 17),
                label: const Text('Email'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onAction('Messaging'),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                label: const Text('Message'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              child: ElevatedButton(
                onPressed: () => onAction('Calling'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                child: const Icon(Icons.call_outlined, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onTap;
  const _MemberTile({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            InitialsAvatar(member: member, size: 46, showStatusDot: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  const SizedBox(height: 2),
                  Text(member.role,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      member.team,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
