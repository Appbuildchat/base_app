import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/color_theme.dart';
import '../../entities/feedback_entity.dart';
import '../../entities/feedback_status.dart';

class UserFeedbackDetailModal extends StatelessWidget {
  final FeedbackEntity feedback;
  final VoidCallback? onClose;

  const UserFeedbackDetailModal({
    super.key,
    required this.feedback,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusL,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenSize.width * 0.95 : 600,
              maxHeight: screenSize.height * 0.85,
            ),
            padding: EdgeInsets.all(isVerySmallScreen ? 16 : 24),
            child: IntrinsicHeight(
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
                              style:
                                  (isVerySmallScreen
                                          ? theme.textTheme.titleLarge
                                          : theme.textTheme.headlineSmall)
                                      ?.copyWith(
                                        fontWeight: AppFontWeights.bold,
                                      ),
                            ),
                            SizedBox(height: isVerySmallScreen ? 4 : 8),
                            _buildStatusChip(theme, isSmallScreen),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        padding: EdgeInsets.all(isVerySmallScreen ? 8 : 12),
                        constraints: BoxConstraints(
                          minWidth: isVerySmallScreen ? 32 : 40,
                          minHeight: isVerySmallScreen ? 32 : 40,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isVerySmallScreen ? 16 : 24),

                  // Content - flexible to match content size
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          _buildSectionHeader(theme, 'Title', isSmallScreen),
                          SizedBox(height: isVerySmallScreen ? 2 : 4),
                          Text(
                            feedback.title,
                            style:
                                (isVerySmallScreen
                                        ? theme.textTheme.titleSmall
                                        : theme.textTheme.titleMedium)
                                    ?.copyWith(
                                      fontWeight: AppFontWeights.semiBold,
                                    ),
                          ),

                          SizedBox(height: isVerySmallScreen ? 12 : 20),

                          // Description
                          _buildSectionHeader(
                            theme,
                            'Description',
                            isSmallScreen,
                          ),
                          SizedBox(height: isVerySmallScreen ? 2 : 4),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: isSmallScreen ? 150 : 200,
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                feedback.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: isVerySmallScreen ? 13 : null,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isVerySmallScreen ? 12 : 20),

                          // Category and Priority Row - stack on very small screens
                          isVerySmallScreen
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category
                                    _buildSectionHeader(
                                      theme,
                                      'Category',
                                      isSmallScreen,
                                    ),
                                    SizedBox(height: 2),
                                    _buildCategoryChip(theme, isSmallScreen),
                                    SizedBox(height: 12),
                                    // Priority
                                    _buildSectionHeader(
                                      theme,
                                      'Priority',
                                      isSmallScreen,
                                    ),
                                    SizedBox(height: 2),
                                    _buildPriorityChip(theme, isSmallScreen),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader(
                                            theme,
                                            'Category',
                                            isSmallScreen,
                                          ),
                                          SizedBox(
                                            height: isSmallScreen ? 2 : 4,
                                          ),
                                          _buildCategoryChip(
                                            theme,
                                            isSmallScreen,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 12 : 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader(
                                            theme,
                                            'Priority',
                                            isSmallScreen,
                                          ),
                                          SizedBox(
                                            height: isSmallScreen ? 2 : 4,
                                          ),
                                          _buildPriorityChip(
                                            theme,
                                            isSmallScreen,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                          SizedBox(height: isVerySmallScreen ? 12 : 20),

                          // Submission Date
                          _buildSectionHeader(
                            theme,
                            'Submitted',
                            isSmallScreen,
                          ),
                          SizedBox(height: isVerySmallScreen ? 2 : 4),
                          Text(
                            _formatDate(feedback.createdAt),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: isVerySmallScreen ? 13 : null,
                            ),
                          ),

                          SizedBox(height: isVerySmallScreen ? 16 : 24),

                          // Admin Response (if exists)
                          if (feedback.adminResponse != null) ...[
                            Container(
                              padding: EdgeInsets.all(
                                isVerySmallScreen ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: AppDimensions.borderRadiusM,
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings,
                                        size: isVerySmallScreen ? 14 : 16,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(
                                        width: isVerySmallScreen ? 6 : 8,
                                      ),
                                      Text(
                                        'Admin Response',
                                        style:
                                            (isVerySmallScreen
                                                    ? theme.textTheme.bodySmall
                                                    : theme
                                                          .textTheme
                                                          .titleSmall)
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight:
                                                      AppFontWeights.semiBold,
                                                ),
                                      ),
                                      if (feedback.adminRespondedAt != null &&
                                          !isVerySmallScreen) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(
                                            feedback.adminRespondedAt!,
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (feedback.adminRespondedAt != null &&
                                      isVerySmallScreen) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      _formatDate(feedback.adminRespondedAt!),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                  SizedBox(height: isVerySmallScreen ? 6 : 8),
                                  Text(
                                    feedback.adminResponse!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: isVerySmallScreen ? 13 : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (feedback.status ==
                              FeedbackStatus.pending) ...[
                            // No response yet message for pending feedback
                            Container(
                              padding: EdgeInsets.all(
                                isVerySmallScreen ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.05),
                                borderRadius: AppDimensions.borderRadiusM,
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    size: isVerySmallScreen ? 14 : 16,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: isVerySmallScreen ? 6 : 8),
                                  Expanded(
                                    child: Text(
                                      'Your feedback is being reviewed by our team. We\'ll respond soon!',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.orange[700],
                                            fontSize: isVerySmallScreen
                                                ? 12
                                                : null,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 300.ms);
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    bool isSmallScreen,
  ) {
    return Text(
      title,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: AppFontWeights.medium,
        fontSize: isSmallScreen ? 11 : null,
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, bool isSmallScreen) {
    final color = _getStatusColor(feedback.status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 4,
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
          fontSize: isSmallScreen ? 10 : 12,
          fontWeight: AppFontWeights.medium,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 4,
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
            size: isSmallScreen ? 14 : 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Flexible(
            child: Text(
              feedback.category.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: AppFontWeights.medium,
                fontSize: isSmallScreen ? 11 : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme, bool isSmallScreen) {
    final color = _getPriorityColor(feedback.priority);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallScreen ? 8 : 10,
            height: isSmallScreen ? 8 : 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: isSmallScreen ? 4 : 6),
          Flexible(
            child: Text(
              feedback.priority.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: AppFontWeights.medium,
                fontSize: isSmallScreen ? 11 : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return Colors.orange;
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
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
