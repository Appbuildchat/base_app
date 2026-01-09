// =============================================================================
// FETCH ADMIN EMAILS FUNCTION
// =============================================================================
//
// This function fetches all admin user emails from Firestore
// Used to display contact information for blocked users
//
// Usage:
// ```dart
// final result = await fetchAdminEmails();
// if (result.isSuccess) {
//   final adminEmails = result.data; // List<String>
//   // Display admin emails to user
// }
// ```
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// Fetch all admin user emails from Firestore
// Returns a list of admin email addresses
Future<Result<List<String>>> fetchAdminEmails() async {
  try {
    // Query users collection where role is 'admin'
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    final adminEmails = <String>[];

    for (final doc in querySnapshot.docs) {
      final userData = doc.data();
      final email = userData['email'] as String?;

      if (email != null && email.isNotEmpty) {
        adminEmails.add(email);
      }
    }

    return Result.success(adminEmails);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<List<String>>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while fetching admin emails: $e',
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
        message: 'Failed to fetch admin emails: ${e.message}',
      );
  }
}
