import 'package:flutter/material.dart';
import '../models/sla_status.dart';
import '../theme/app_colors.dart';

class SlaBadge extends StatelessWidget {
  final SlaStatus status;
  final bool compact;

  const SlaBadge({super.key, required this.status, this.compact = false});

  _SlaVisual get _visual {
    switch (status) {
      case SlaStatus.onTrack:
        return _SlaVisual(AppColors.onTrack, AppColors.onTrackBg, Icons.schedule);
      case SlaStatus.atRisk:
        return _SlaVisual(AppColors.atRisk, AppColors.atRiskBg, Icons.warning_amber_rounded);
      case SlaStatus.overdue:
        return _SlaVisual(AppColors.overdue, AppColors.overdueBg, Icons.error_outline_rounded);
      case SlaStatus.completed:
        return _SlaVisual(AppColors.completed, AppColors.completedBg, Icons.check_circle_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: v.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: v.fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(v.icon, size: compact ? 12 : 14, color: v.fg),
          const SizedBox(width: 4),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              color: v.fg,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10.5 : 11.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlaVisual {
  final Color fg;
  final Color bg;
  final IconData icon;
  _SlaVisual(this.fg, this.bg, this.icon);
}
