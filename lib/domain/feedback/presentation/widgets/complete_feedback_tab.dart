// =============================================================================
// COMPLETE FEEDBACK TAB WIDGET
// Separated widget for the completed feedback list tab
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../entities/feedback_entity.dart';
import 'user_feedback_card.dart';
import 'feedback_error_state.dart';
import 'feedback_empty_state.dart';

class CompleteFeedbackTab extends StatelessWidget {
  final List<FeedbackEntity> completeFeedbacks;
  final bool isLoadingFeedbacks;
  final String? feedbackError;
  final Future<void> Function() onRefresh;
  final ValueChanged<FeedbackEntity> onFeedbackTap;

  const CompleteFeedbackTab({
    super.key,
    required this.completeFeedbacks,
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
          : completeFeedbacks.isEmpty
          ? const FeedbackEmptyState(
              title: 'No completed feedback',
              message: 'You don\'t have any completed feedback at the moment.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                left: AppSpacing.l,
                right: AppSpacing.l,
                top: AppSpacing.l,
                bottom: AppSpacing.xl * 2,
              ),
              itemCount: completeFeedbacks.length,
              itemBuilder: (context, index) {
                final feedback = completeFeedbacks[index];
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
