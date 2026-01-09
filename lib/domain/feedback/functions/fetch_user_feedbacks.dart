// =============================================================================
// FETCH USER FEEDBACKS FUNCTION
// =============================================================================
//
// Fetch feedbacks by specific user ID
// Returns feedbacks sorted by creation date (newest first)
//
// Usage:
// final result = await fetchUserFeedbacks(userId: 'user123');
// if (result.isSuccess) {
//   final feedbacks = result.data!;
// }
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/feedback_entity.dart';
import 'firebase_error_handler.dart';

// Fetch feedbacks by specific user
Future<Result<List<FeedbackEntity>>> fetchUserFeedbacks({
  required String userId,
  int? limit,
}) async {
  try {
    if (userId.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'User ID is required',
      );
    }

    Query query = FirebaseFirestore.instance
        .collection('feedbacks')
        .where('userId', isEqualTo: userId.trim())
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
      message: 'An unexpected error occurred while fetching user feedbacks: $e',
    );
  }
}
