import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';

class FeedbackEmptyState extends StatelessWidget {
  const FeedbackEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.feedback_outlined,
                size: AppDimensions.iconXXL * 2,
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),
              AppSpacing.v16,
              Text(
                'No feedbacks found',
                style: AppTypography.headline3.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              AppSpacing.v8,
              Text(
                'There are no feedbacks matching your filters.',
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.secondary.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 800.ms);
  }
}
