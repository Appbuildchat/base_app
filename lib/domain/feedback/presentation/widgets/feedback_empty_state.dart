// =============================================================================
// FEEDBACK EMPTY STATE WIDGET
// Separated widget for displaying empty states in feedback screens
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';

class FeedbackEmptyState extends StatelessWidget {
  final String title;
  final String message;

  const FeedbackEmptyState({
    super.key,
    required this.title,
    required this.message,
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
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
          AppSpacing.v8,
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
