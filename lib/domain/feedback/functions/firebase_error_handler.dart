// =============================================================================
// FIREBASE ERROR HANDLER UTILITY
// =============================================================================
//
// Common error handling utility for Firebase operations
// Used across all feedback-related functions
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// Handle Firebase-specific errors
Result<T> handleFirebaseError<T>(FirebaseException e) {
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
        message: 'Failed to process request: ${e.message}',
      );
  }
}
