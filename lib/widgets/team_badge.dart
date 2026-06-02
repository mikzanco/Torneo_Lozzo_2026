import 'package:flutter/material.dart';
import '../models/team.dart';
import '../theme/app_theme.dart';

enum BadgeSize { sm, md, lg }

class TeamBadge extends StatelessWidget {
  final Team? team;
  final BadgeSize size;

  const TeamBadge({
    Key? key,
    required this.team,
    this.size = BadgeSize.md,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double dimensions;
    double radius;
    double fontSize;

    switch (size) {
      case BadgeSize.sm:
        dimensions = 36.0;
        radius = 12.0;
        fontSize = 12.0;
        break;
      case BadgeSize.md:
        dimensions = 48.0;
        radius = 16.0;
        fontSize = 14.0;
        break;
      case BadgeSize.lg:
        dimensions = 64.0;
        radius = 16.0;
        fontSize = 20.0;
        break;
    }

    if (team == null) {
      // Placeholder TBD
      return Container(
        width: dimensions,
        height: dimensions,
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          border: Border.all(color: AppColors.borderDark, width: 2),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(
          child: Text(
            "?",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    final colors = TeamColors.gradients[team!.color.clamp(0, TeamColors.gradients.length - 1)];

    return Container(
      width: dimensions,
      height: dimensions,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors[1].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          team!.initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
