import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// Check if the current user is blocked by admin
// Returns true if blocked, false if not blocked
//
// This function checks if the currently authenticated user is blocked by admin
// Used during login process to prevent blocked users from accessing the app
//
// Usage:
// ```dart
// final result = await checkUserBlocked();
// if (result.isSuccess && result.data == true) {
//   // User is blocked, show blocked modal
// } else if (result.isSuccess && result.data == false) {
//   // User is not blocked, proceed with login
// } else {
//   // Error occurred, handle appropriately
// }
// ```
Future<Result<bool>> checkUserBlocked() async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'No authenticated user found',
      );
    }

    // Get user document from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) {
      // If user document doesn't exist, consider not blocked
      return Result.success(false);
    }

    final userData = userDoc.data()!;
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
    case 'not-found':
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'User data not found.',
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
