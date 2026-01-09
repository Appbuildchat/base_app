// =============================================================================
// GET FEEDBACK STATISTICS FUNCTION
// =============================================================================
//
// Get comprehensive feedback statistics for dashboard
// Returns statistics about feedback counts by status, category, priority
//
// Usage:
// final result = await getFeedbackStatistics();
// if (result.isSuccess) {
//   final stats = result.data!;
// }
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/feedback_entity.dart';
import '../entities/feedback_status.dart';
import 'firebase_error_handler.dart';

// Get feedback statistics for dashboard
Future<Result<Map<String, int>>> getFeedbackStatistics() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('feedbacks')
        .get();

    final feedbacks = snapshot.docs.map((doc) {
      final data = doc.data();
      return FeedbackEntity.fromJson(data);
    }).toList();

    final stats = <String, int>{
      'total': feedbacks.length,
      'pending': feedbacks
          .where((f) => f.status == FeedbackStatus.pending)
          .length,
      'complete': feedbacks
          .where((f) => f.status == FeedbackStatus.complete)
          .length,
      'bugs': feedbacks.where((f) => f.category == FeedbackCategory.bug).length,
      'features': feedbacks
          .where((f) => f.category == FeedbackCategory.feature)
          .length,
      'high_priority': feedbacks
          .where(
            (f) =>
                f.priority == FeedbackPriority.high ||
                f.priority == FeedbackPriority.critical,
          )
          .length,
    };

    return Result.success(stats);
  } on FirebaseException catch (e) {
    return handleFirebaseError<Map<String, int>>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message:
          'An unexpected error occurred while fetching feedback statistics: $e',
    );
  }
}
