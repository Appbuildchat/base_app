// =============================================================================
// REAUTHENTICATE USER
// =============================================================================
//
// This function re-authenticates the current user with their email and password.
// This is required for sensitive operations like account deletion when the user
// hasn't logged in recently (within 5 minutes).
//
// Usage:
// ```dart
// try {
//   await reauthenticateUser('user@email.com', 'password');
//   // Now user can perform sensitive operations
// } catch (e) {
//   // Handle re-authentication failure
// }
// ```
//
// - Required for Firebase operations that need recent authentication
// - Refreshes the authentication token
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

Future<void> reauthenticateUser(String email, String password) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    throw Exception('No user is currently logged in');
  }

  if (email.isEmpty || password.isEmpty) {
    throw Exception('Email and password are required');
  }

  try {
    debugPrint('[REAUTH] Starting re-authentication for: $email');

    // Create credentials with email and password
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );

    // Re-authenticate the user
    await currentUser.reauthenticateWithCredential(credential);

    debugPrint('[REAUTH] Re-authentication successful');
  } on FirebaseAuthException catch (e) {
    debugPrint('[REAUTH] Firebase Auth error: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'wrong-password':
        throw Exception('The password you entered is incorrect');
      case 'invalid-email':
        throw Exception('The email address is not valid');
      case 'user-not-found':
        throw Exception('No user found with this email');
      case 'too-many-requests':
        throw Exception('Too many failed attempts. Please try again later');
      case 'user-disabled':
        throw Exception('This user account has been disabled');
      case 'invalid-credential':
        throw Exception('The credentials provided are invalid');
      default:
        throw Exception(
          'Authentication failed: ${e.message ?? 'Unknown error'}',
        );
    }
  } catch (e) {
    debugPrint('[REAUTH] Unexpected error: $e');
    throw Exception(
      'An unexpected error occurred during re-authentication: $e',
    );
  }
}

// Re-authenticate using the current user's email (convenience method)
Future<Result<void>> reauthenticateCurrentUser(String password) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser?.email == null) {
    return Result.failure(
      AppErrorCode.authNotLoggedIn,
      message: 'Current user email is not available',
    );
  }

  try {
    await reauthenticateUser(currentUser!.email!, password);
    return Result.success(null);
  } catch (e) {
    return Result.failure(
      AppErrorCode.authProcessAborted,
      message: e.toString(),
    );
  }
}
