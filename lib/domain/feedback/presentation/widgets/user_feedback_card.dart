import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_theme.dart';
import '../../entities/feedback_entity.dart';
import '../../entities/feedback_status.dart';

class UserFeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final int index;
  final VoidCallback? onTap;

  const UserFeedbackCard({
    super.key,
    required this.feedback,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            decoration: BoxDecoration(
              color: AppCommonColors.white,
              borderRadius: AppDimensions.borderRadiusM,
              boxShadow: AppShadows.card,
            ),
            child: Padding(
              padding: AppSpacing.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row with Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          feedback.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: AppFontWeights.semiBold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.h12,
                      _buildStatusChip(),
                    ],
                  ),

                  AppSpacing.v12,

                  // Description
                  Text(
                    feedback.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  AppSpacing.v12,

                  // Category and Priority
                  Row(
                    children: [
                      _buildCategoryChip(theme),
                      AppSpacing.h8,
                      _buildPriorityChip(theme),
                      const Spacer(),
                      Text(
                        _formatDate(feedback.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.05, end: 0, duration: 600.ms);
  }

  Widget _buildStatusChip() {
    final color = _getStatusColor(feedback.status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusS,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        feedback.status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: AppFontWeights.medium,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppDimensions.borderRadiusS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feedback.category.icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.h4,
          Text(
            feedback.category.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: AppFontWeights.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    final color = _getPriorityColor(feedback.priority);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          AppSpacing.h4,
          Text(
            feedback.priority.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: AppFontWeights.medium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return AppCommonColors.orange;
      case FeedbackStatus.complete:
        return AppCommonColors.green;
    }
  }

  Color _getPriorityColor(FeedbackPriority priority) {
    switch (priority) {
      case FeedbackPriority.low:
        return AppCommonColors.green;
      case FeedbackPriority.medium:
        return AppCommonColors.orange;
      case FeedbackPriority.high:
        return AppCommonColors.red;
      case FeedbackPriority.critical:
        return AppCommonColors.purple;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
