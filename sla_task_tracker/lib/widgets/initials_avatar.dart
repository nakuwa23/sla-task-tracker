import 'package:flutter/material.dart';
import '../models/team_member.dart';
import '../theme/app_colors.dart';

class InitialsAvatar extends StatelessWidget {
  final TeamMember? member;
  final double size;
  final bool showStatusDot;

  const InitialsAvatar({
    super.key,
    required this.member,
    this.size = 44,
    this.showStatusDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = member?.avatarColor ?? AppColors.border;
    final initials = member?.initials ?? '?';

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
          color: AppColors.textPrimary,
        ),
      ),
    );

    if (!showStatusDot || member == null) return circle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: member!.isAvailable ? AppColors.onTrack : AppColors.textMuted,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
