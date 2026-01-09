// ============================================================================
// SEND PASSWORD RESET EMAIL
// ============================================================================
//
// This function sends a password reset email to the provided email address
// using Firebase Auth.
//
// Processing flow:
// 1. Email format validation
// 2. Check if email exists in Firestore
// 3. Send password reset email via Firebase Auth
//
// Usage example:
// ```dart
// final result = await sendPasswordResetEmail('test@email.com');
// if (result.isSuccess) {
//   // Handle success
// } else {
//   // Handle error: result.error and result.message
// }
// ```
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/validators.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

Future<Result<void>> sendPasswordResetEmail(String email) async {
  // 1. Email format validation
  if (Validators.email(email) != null) {
    return Result.failure(
      AppErrorCode.authInvalidEmailFormat,
      message: 'Invalid email format',
    );
  }

  try {
    // 2. Send password reset email directly via Firebase Auth
    // Firebase Auth will handle checking if the user exists
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return Result.success(null);
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        return Result.failure(
          AppErrorCode.authCredentialsNotFound,
          message: 'No account found with this email address',
        );
      case 'invalid-email':
        return Result.failure(
          AppErrorCode.authInvalidEmailFormat,
          message: 'Invalid email address format',
        );
      case 'too-many-requests':
        return Result.failure(
          AppErrorCode.authTooManyRequests,
          message: 'Too many requests. Please try again later',
        );
      default:
        return Result.failure(
          AppErrorCode.authUnknownError,
          message: e.message ?? 'Failed to send reset email',
        );
    }
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred: $e',
    );
  }
}
