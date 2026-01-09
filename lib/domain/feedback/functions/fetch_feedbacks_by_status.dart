// =============================================================================
// FETCH FEEDBACKS BY STATUS FUNCTION
// =============================================================================
//
// Fetch feedbacks filtered by status
// Returns feedbacks sorted by creation date (newest first)
//
// Usage:
// final result = await fetchFeedbacksByStatus(status: FeedbackStatus.pending);
// if (result.isSuccess) {
//   final feedbacks = result.data!;
// }
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/feedback_entity.dart';
import '../entities/feedback_status.dart';
import 'firebase_error_handler.dart';

// Fetch feedbacks by status
Future<Result<List<FeedbackEntity>>> fetchFeedbacksByStatus({
  required FeedbackStatus status,
  int? limit,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('feedbacks')
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    final feedbacks = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FeedbackEntity.fromJson(data);
    }).toList();

    return Result.success(feedbacks);
  } on FirebaseException catch (e) {
    return handleFirebaseError<List<FeedbackEntity>>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message:
          'An unexpected error occurred while fetching feedbacks by status: $e',
    );
  }
}
