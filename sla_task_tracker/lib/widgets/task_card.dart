import 'package:flutter/material.dart';
import '../models/sla_status.dart';
import '../models/task.dart';
import '../models/team_member.dart';
import '../services/sla_calculator.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import 'initials_avatar.dart';
import 'sla_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final TeamMember? assignee;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.assignee,
    required this.onTap,
  });

  Color _statusColor(SlaStatus status) {
    switch (status) {
      case SlaStatus.onTrack:
        return AppColors.onTrack;
      case SlaStatus.atRisk:
        return AppColors.atRisk;
      case SlaStatus.overdue:
        return AppColors.overdue;
      case SlaStatus.completed:
        return AppColors.completed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = SlaCalculator.statusFor(task);
    final barColor = _statusColor(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          InitialsAvatar(member: assignee, size: 28),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SlaBadge(status: status, compact: true),
                          const SizedBox(width: 8),
                          Text(
                            task.id,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 5),
                          Text(
                            AppDateUtils.formatDate(task.dueDate),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: task.timeProgress,
                          minHeight: 5,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(barColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
