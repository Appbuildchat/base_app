import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';
import '../../../../../core/themes/app_shadows.dart';
import '../../../../../core/themes/app_font_weights.dart';
import '../../../../feedback/entities/feedback_entity.dart';
import '../../../../feedback/entities/feedback_status.dart';
import 'feedback_status_chip.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onRespond;
  final VoidCallback? onDelete;

  const FeedbackCard({
    super.key,
    required this.feedback,
    required this.index,
    this.onTap,
    this.onViewDetails,
    this.onRespond,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Title: ',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.secondary,
                                                fontWeight:
                                                    AppFontWeights.medium,
                                              ),
                                        ),
                                        TextSpan(
                                          text: feedback.title,
                                          style: AppTypography.bodyRegular
                                              .copyWith(
                                                fontWeight:
                                                    AppFontWeights.semiBold,
                                                color: AppColors.text,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AppSpacing.h12,
                                FeedbackStatusChip(
                                  text: feedback.status.displayName,
                                  color: _getStatusColor(feedback.status),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 3-dot menu positioned at top right
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              onViewDetails?.call();
                              break;
                            case 'respond':
                              onRespond?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  size: AppDimensions.iconS + 2,
                                ),
                                AppSpacing.h8,
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'respond',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: AppDimensions.iconS + 2,
                                ),
                                AppSpacing.h8,
                                Text('Mark as Completed'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: AppDimensions.iconS + 2,
                                ),
                                AppSpacing.h8,
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  AppSpacing.v12,

                  // Contents
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Contents: ',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: AppFontWeights.medium,
                          ),
                        ),
                        TextSpan(
                          text: feedback.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.v12,

                  // Category and Priority
                  Row(
                    children: [
                      FeedbackStatusChip(
                        text: feedback.category.displayName,
                        color: AppColors.secondary,
                      ),
                      AppSpacing.h8,
                      FeedbackStatusChip(
                        text: feedback.priority.displayName,
                        color: _getPriorityColor(feedback.priority),
                      ),
                    ],
                  ),

                  AppSpacing.v8,

                  // User info and date
                  Text(
                    'By: ${feedback.userFirstName} ${feedback.userLastName} • ${_formatDate(feedback.createdAt)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondary.withValues(alpha: 0.7),
                    ),
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
