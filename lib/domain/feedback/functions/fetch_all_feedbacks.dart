// =============================================================================
// FETCH ALL FEEDBACKS FUNCTION
// =============================================================================
//
// Fetch all feedbacks with pagination support
// Returns feedbacks sorted by creation date (newest first)
//
// Usage:
// final result = await fetchAllFeedbacks();
// if (result.isSuccess) {
//   final feedbacks = result.data!;
// }
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/feedback_entity.dart';
import 'firebase_error_handler.dart';

// Fetch all feedbacks (Admin only)
// Returns feedbacks sorted by creation date (newest first)
Future<Result<List<FeedbackEntity>>> fetchAllFeedbacks({
  int? limit,
  DocumentSnapshot? startAfter,
}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('feedbacks')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
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
      message: 'An unexpected error occurred while fetching feedbacks: $e',
    );
  }
}
