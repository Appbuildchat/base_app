// =============================================================================
// CHECK USER BLOCKED BY EMAIL FUNCTION
// =============================================================================
//
// This function checks if a user is blocked by admin using their email
// Used before login to prevent blocked users from authenticating
//
// Usage:
// ```dart
// final result = await checkUserBlockedByEmail('user@example.com');
// if (result.isSuccess && result.data == true) {
//   // User is blocked, show blocked modal and don't proceed with login
// } else if (result.isSuccess && result.data == false) {
//   // User is not blocked, proceed with login
// } else {
//   // Error occurred or user not found, proceed with login (Firebase will handle)
// }
// ```
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// Check if a user is blocked by admin using their email
// Returns true if blocked, false if not blocked or user not found
Future<Result<bool>> checkUserBlockedByEmail(String email) async {
  try {
    // Query users collection by email
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // User not found in Firestore, consider not blocked
      // (Firebase Auth will handle the actual authentication)
      return Result.success(false);
    }

    final userData = querySnapshot.docs.first.data();
    final isBlocked = userData['adminblocked'] ?? false;

    return Result.success(isBlocked);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<bool>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while checking user status: $e',
    );
  }
}

// Handle Firebase-specific errors
Result<T> _handleFirebaseError<T>(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return Result.failure(
        AppErrorCode.permissionDenied,
        message: 'Permission denied to access user data.',
      );
    case 'unavailable':
      return Result.failure(
        AppErrorCode.networkError,
        message: 'Service temporarily unavailable. Please try again.',
      );
    default:
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Failed to check user status: ${e.message}',
      );
  }
}
