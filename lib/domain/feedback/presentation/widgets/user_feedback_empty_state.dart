import 'package:flutter/material.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';

class UserFeedbackEmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? action;

  const UserFeedbackEmptyState({
    super.key,
    this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          AppSpacing.v16,
          Text(
            title ?? 'No feedback yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFontWeights.semiBold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.v8,
          Text(
            message ?? 'You haven\'t submitted any feedback yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[AppSpacing.v24, action!],
        ],
      ),
    );
  }
}
