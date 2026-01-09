import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';
import '../../../../../core/themes/app_font_weights.dart';
import '../../../../feedback/entities/feedback_entity.dart';
import '../../../../feedback/entities/feedback_status.dart';
import 'feedback_status_chip.dart';

class FeedbackDetailModal extends StatelessWidget {
  final FeedbackEntity feedback;
  final VoidCallback? onClose;
  final VoidCallback? onRespond;
  final VoidCallback? onStatusChange;

  const FeedbackDetailModal({
    super.key,
    required this.feedback,
    this.onClose,
    this.onRespond,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusL),
      child:
          Container(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 700,
                ),
                padding: AppSpacing.paddingL,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Feedback Details',
                                style: AppTypography.headline3.copyWith(
                                  fontWeight: AppFontWeights.bold,
                                ),
                              ),
                              AppSpacing.v4,
                              FeedbackStatusChip(
                                text: feedback.status.displayName,
                                color: _getStatusColor(feedback.status),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed:
                              onClose ?? () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),

                    AppSpacing.v24,

                    // User Info
                    Container(
                      padding: AppSpacing.paddingM,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              feedback.userFirstName.isNotEmpty
                                  ? feedback.userFirstName[0].toUpperCase()
                                  : '?',
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.primary,
                                fontWeight: AppFontWeights.bold,
                              ),
                            ),
                          ),
                          AppSpacing.h12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${feedback.userFirstName} ${feedback.userLastName}',
                                  style: AppTypography.bodyRegular.copyWith(
                                    fontWeight: AppFontWeights.semiBold,
                                  ),
                                ),
                                Text(
                                  feedback.userEmail,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.v20,

                    // Title
                    Text(
                      'Title:',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      feedback.title,
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: AppFontWeights.semiBold,
                      ),
                    ),

                    AppSpacing.v20,

                    // Contents
                    Text(
                      'Contents:',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                    AppSpacing.v4,
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Text(
                          feedback.description,
                          style: AppTypography.bodyRegular,
                        ),
                      ),
                    ),

                    AppSpacing.v12,

                    // Metadata
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            AppSpacing.v4,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: AppDimensions.borderRadiusS,
                              ),
                              child: Text(
                                feedback.category.displayName,
                                style: AppTypography.bodySmall,
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.v16,

                        // Priority
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            AppSpacing.v4,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  feedback.priority,
                                ).withValues(alpha: 0.1),
                                borderRadius: AppDimensions.borderRadiusS,
                              ),
                              child: Text(
                                feedback.priority.displayName,
                                style: AppTypography.bodySmall.copyWith(
                                  color: _getPriorityColor(feedback.priority),
                                ),
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.v16,

                        // Submitted
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submitted',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            AppSpacing.v4,
                            Text(
                              _formatDate(feedback.createdAt),
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),

                    AppSpacing.v24,

                    // Admin Response (if exists)
                    if (feedback.adminResponse != null) ...[
                      Container(
                        padding: AppSpacing.paddingM,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: AppDimensions.borderRadiusM,
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                AppSpacing.h8,
                                Text(
                                  'Admin Response',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.blue,
                                    fontWeight: AppFontWeights.semiBold,
                                  ),
                                ),
                                if (feedback.adminRespondedAt != null) ...[
                                  const Spacer(),
                                  Text(
                                    _formatDate(feedback.adminRespondedAt!),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            AppSpacing.v8,
                            Text(
                              feedback.adminResponse!,
                              style: AppTypography.bodyRegular,
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v24,
                    ],

                    // Action Buttons
                    if (feedback.adminResponse == null &&
                        feedback.status == FeedbackStatus.pending) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: onRespond,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Mark as Completed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppCommonColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9), duration: 300.ms),
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

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
