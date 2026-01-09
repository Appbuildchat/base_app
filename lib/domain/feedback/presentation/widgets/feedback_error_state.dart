// =============================================================================
// FEEDBACK ERROR STATE WIDGET
// Separated widget for displaying error states in feedback screens
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';

class FeedbackErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const FeedbackErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          AppSpacing.v16,
          Text(
            'Failed to load feedback',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
          AppSpacing.v8,
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.v24,
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
