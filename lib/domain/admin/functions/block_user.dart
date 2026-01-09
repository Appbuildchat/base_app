import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// Block or unblock a user (admin only)
//
// This function allows admin users to block/unblock users by updating
// the 'adminblocked' field in their Firestore document
//
// Usage:
// ```dart
// // Block user
// final result = await blockUser(userId: 'user123', block: true);
// if (result.isSuccess) {
//   print('User blocked successfully');
// }
//
// // Unblock user
// final result = await blockUser(userId: 'user123', block: false);
// if (result.isSuccess) {
//   print('User unblocked successfully');
// }
// ```
Future<Result<bool>> blockUser({
  required String userId,
  required bool block,
}) async {
  try {
    if (userId.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'User ID is required',
      );
    }

    // Update the adminblocked field in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId.trim())
        .update({
          'adminblocked': block,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    return Result.success(true);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<bool>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message:
          'An unexpected error occurred while ${block ? 'blocking' : 'unblocking'} user: $e',
    );
  }
}

// Handle Firebase-specific errors
Result<T> _handleFirebaseError<T>(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return Result.failure(
        AppErrorCode.permissionDenied,
        message: 'Permission denied. Admin access required.',
      );
    case 'not-found':
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'User not found.',
      );
    case 'unavailable':
      return Result.failure(
        AppErrorCode.networkError,
        message: 'Service temporarily unavailable. Please try again.',
      );
    default:
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Failed to update user: ${e.message}',
      );
  }
}
