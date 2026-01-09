// =============================================================================
// SUBMIT FEEDBACK FUNCTION
// =============================================================================
//
// This function allows users to submit feedback to the system
// Stores feedback data in Firestore with proper validation
//
// Usage:
// final result = await submitFeedback(
//   userId: currentUser.uid,
//   userFirstName: 'John',
//   userLastName: 'Doe',
//   userEmail: currentUser.email,
//   title: 'Bug in profile screen',
//   description: 'Detailed description of the issue',
//   category: FeedbackCategory.bug,
//   priority: FeedbackPriority.medium,
//   attachments: ['url1', 'url2'],
// );
//
// if (result.isSuccess) {
//   // Feedback submitted successfully
//   final feedbackId = result.data!;
// } else {
//   // Handle error
//   print('Error: ${result.error}');
// }
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/feedback_entity.dart';
import '../entities/feedback_status.dart';

Future<Result<String>> submitFeedback({
  required String userId,
  required String userFirstName,
  required String userLastName,
  required String userEmail,
  required String title,
  required String description,
  required FeedbackCategory category,
  required FeedbackPriority priority,
  List<String> attachments = const [],
}) async {
  try {
    // Input validation
    if (userId.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'User ID is required',
      );
    }

    if (userFirstName.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'User first name is required',
      );
    }

    if (userEmail.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'User email is required',
      );
    }

    if (title.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Feedback title is required',
      );
    }

    if (title.trim().length < 3) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Title must be at least 3 characters long',
      );
    }

    if (title.trim().length > 100) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Title must be less than 100 characters',
      );
    }

    if (description.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Feedback description is required',
      );
    }

    if (description.trim().length < 10) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Description must be at least 10 characters long',
      );
    }

    if (description.trim().length > 1000) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Description must be less than 1000 characters',
      );
    }

    // Generate unique feedback ID
    final feedbackId = FirebaseFirestore.instance
        .collection('feedbacks')
        .doc()
        .id;
    final now = DateTime.now();

    // Create feedback entity
    final feedback = FeedbackEntity(
      feedbackId: feedbackId,
      userId: userId.trim(),
      userFirstName: userFirstName.trim(),
      userLastName: userLastName.trim(),
      userEmail: userEmail.trim(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      priority: priority,
      status: FeedbackStatus.pending,
      attachments: attachments,
      createdAt: now,
      updatedAt: now,
    );

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(feedbackId)
        .set(feedback.toJson());

    return Result.success(feedbackId);
  } on FirebaseException catch (e) {
    // Handle Firebase-specific errors
    switch (e.code) {
      case 'permission-denied':
        return Result.failure(
          AppErrorCode.permissionDenied,
          message: 'Permission denied. Please check your access rights.',
        );
      case 'unavailable':
        return Result.failure(
          AppErrorCode.networkError,
          message: 'Service temporarily unavailable. Please try again.',
        );
      case 'quota-exceeded':
        return Result.failure(
          AppErrorCode.backendServiceUnavailable,
          message: 'Storage quota exceeded. Please try again later.',
        );
      default:
        return Result.failure(
          AppErrorCode.backendUnknownError,
          message: 'Failed to submit feedback: ${e.message}',
        );
    }
  } catch (e) {
    // Handle unexpected errors
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while submitting feedback: $e',
    );
  }
}
