import 'package:flutter/material.dart';

import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/app_font_weights.dart';

class FeedbackStatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const FeedbackStatusChip({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: AppFontWeights.medium,
        ),
      ),
    );
  }
}
