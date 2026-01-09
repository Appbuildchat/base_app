// =============================================================================
// PENDING FEEDBACK TAB WIDGET
// Separated widget for the pending feedback list tab
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../entities/feedback_entity.dart';
import 'user_feedback_card.dart';
import 'feedback_error_state.dart';
import 'feedback_empty_state.dart';

class PendingFeedbackTab extends StatelessWidget {
  final List<FeedbackEntity> pendingFeedbacks;
  final bool isLoadingFeedbacks;
  final String? feedbackError;
  final Future<void> Function() onRefresh;
  final ValueChanged<FeedbackEntity> onFeedbackTap;

  const PendingFeedbackTab({
    super.key,
    required this.pendingFeedbacks,
    required this.isLoadingFeedbacks,
    required this.feedbackError,
    required this.onRefresh,
    required this.onFeedbackTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: isLoadingFeedbacks
          ? const Center(child: CircularProgressIndicator())
          : feedbackError != null
          ? FeedbackErrorState(error: feedbackError!, onRetry: onRefresh)
          : pendingFeedbacks.isEmpty
          ? const FeedbackEmptyState(
              title: 'No pending feedback',
              message: 'You don\'t have any pending feedback at the moment.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                left: AppSpacing.l,
                right: AppSpacing.l,
                top: AppSpacing.l,
                bottom: AppSpacing.xl * 2,
              ),
              itemCount: pendingFeedbacks.length,
              itemBuilder: (context, index) {
                final feedback = pendingFeedbacks[index];
                return UserFeedbackCard(
                  feedback: feedback,
                  index: index,
                  onTap: () => onFeedbackTap(feedback),
                );
              },
            ),
    );
  }
}
