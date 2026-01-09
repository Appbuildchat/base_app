import 'package:flutter/material.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';
import '../../../../../core/themes/app_shadows.dart';
import '../../../../../core/themes/app_font_weights.dart';
import '../../../../../core/themes/app_theme.dart';

class UserStatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const UserStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppSpacing.paddingL,
        decoration: BoxDecoration(
          color: AppCommonColors.white,
          borderRadius: AppDimensions.borderRadiusM,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppDimensions.iconL),
            AppSpacing.v8,
            Text(
              value.toString(),
              style: AppTypography.headline3.copyWith(
                color: color,
                fontWeight: AppFontWeights.bold,
              ),
            ),
            AppSpacing.v4,
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
