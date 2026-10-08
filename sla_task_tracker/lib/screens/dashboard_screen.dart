import 'package:flutter/material.dart';
import '../models/team_member.dart';
import '../services/data_store.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _refreshAfterReturn() async {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    final activity = store.activityLog.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Project Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                store.currentUser != null
                    ? '${store.currentUser!.team} · ${store.members.length} members'
                    : 'Team overview',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAfterReturn,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Active tasks',
                    value: '${store.activeTasksCount}',
                    dotColor: AppColors.onTrack,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'SLA at risk',
                    value: '${store.atRiskCount}',
                    dotColor: AppColors.atRisk,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: 'Overdue',
                    value: '${store.overdueCount}',
                    dotColor: AppColors.overdue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SlaHealthCard(store: store),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Recent Activity',
              actionLabel: 'View All',
              onAction: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _ActivityLogSheet(store: store),
                );
              },
            ),
            const SizedBox(height: 10),
            if (activity.isEmpty)
              const EmptyState(
                icon: Icons.history_rounded,
                title: 'No activity yet',
                message: 'Task updates and completions will show up here.',
              )
            else
              ...activity.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InitialsAvatar(
                          member: _memberByName(store, entry.actorName),
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.actorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    AppDateUtils.timeAgo(entry.timestamp),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.message,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

TeamMember? _memberByName(DataStore store, String name) {
  for (final m in store.members) {
    if (m.name == name) return m;
  }
  return null;
}

class _SlaHealthCard extends StatelessWidget {
  final DataStore store;
  const _SlaHealthCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final total = store.totalCount == 0 ? 1 : store.totalCount;
    final onTrack = store.onTrackCount;
    final atRisk = store.atRiskCount;
    final overdue = store.overdueCount;
    final completed = store.completedCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SLA Breakdown',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                '${store.totalCount} total tasks',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${(store.overallProgress * 100).round()}% of all tasks completed',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  if (onTrack > 0)
                    Expanded(flex: onTrack, child: Container(color: AppColors.onTrack)),
                  if (atRisk > 0)
                    Expanded(flex: atRisk, child: Container(color: AppColors.atRisk)),
                  if (overdue > 0)
                    Expanded(flex: overdue, child: Container(color: AppColors.overdue)),
                  if (completed > 0)
                    Expanded(flex: completed, child: Container(color: AppColors.completed)),
                  if (onTrack + atRisk + overdue + completed == 0)
                    Expanded(flex: total, child: Container(color: AppColors.border)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendDot(color: AppColors.onTrack, label: 'On Track ($onTrack)'),
              _LegendDot(color: AppColors.atRisk, label: 'At Risk ($atRisk)'),
              _LegendDot(color: AppColors.overdue, label: 'Overdue ($overdue)'),
              _LegendDot(color: AppColors.completed, label: 'Completed ($completed)'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ActivityLogSheet extends StatelessWidget {
  final DataStore store;
  const _ActivityLogSheet({required this.store});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('All Activity',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            ),
            Expanded(
              child: store.activityLog.isEmpty
                  ? const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No activity yet',
                      message: 'Task updates and completions will show up here.',
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: store.activityLog.length,
                      separatorBuilder: (_, __) => const Divider(height: 20),
                      itemBuilder: (context, i) {
                        final entry = store.activityLog[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      color: AppColors.textPrimary, fontSize: 13.5),
                                  children: [
                                    TextSpan(
                                      text: '${entry.actorName} ',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    TextSpan(text: entry.message),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppDateUtils.timeAgo(entry.timestamp),
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
