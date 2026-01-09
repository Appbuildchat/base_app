// ============================================================================
// DELETE USER ACCOUNT
// ============================================================================
//
// This function deletes the current user from Firebase Auth and
// removes the corresponding user document from the Firestore users collection.
//
// Usage:
// ```dart
// final result = await deleteUserAccount();
// if (result.isSuccess) {
//   // Handle successful account deletion
// } else {
//   // Handle failure: result.error and result.message
// }
// ```
//
// - Deleting a Firebase Auth user requires recent login status.
// - User should be re-authenticated before calling this function.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

Future<Result<void>> deleteUserAccount() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return Result.failure(
      AppErrorCode.authNotLoggedIn,
      message: "No user logged in.",
    );
  }

  final userId = currentUser.uid;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  debugPrint('[DELETE] Starting account deletion for user: $userId');

  // 1. Delete Firestore user document first
  try {
    debugPrint('[DELETE] Deleting Firestore user document...');
    await usersCollection.doc(userId).delete();
    debugPrint('[DELETE] Firestore user document deleted successfully');
  } catch (e) {
    debugPrint('[DELETE] Failed to delete Firestore document: $e');
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: "Failed to delete user data: $e",
    );
  }

  // 2. Delete Firebase Auth user
  try {
    debugPrint('[DELETE] Deleting Firebase Auth user...');
    await currentUser.delete();
    debugPrint('[DELETE] Firebase Auth user deleted successfully');
    return Result.success(null);
  } on FirebaseAuthException catch (e) {
    debugPrint('[DELETE] Firebase Auth error: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'requires-recent-login':
        return Result.failure(
          AppErrorCode.authNotLoggedIn,
          message: "Session expired. Please re-authenticate and try again.",
        );
      case 'user-not-found':
        return Result.failure(
          AppErrorCode.authCredentialsNotFound,
          message: "User account not found.",
        );
      case 'user-disabled':
        return Result.failure(
          AppErrorCode.authUserDisabled,
          message: "User account is disabled.",
        );
      case 'invalid-user-token':
        return Result.failure(
          AppErrorCode.authNotLoggedIn,
          message: "Authentication token is invalid. Please log in again.",
        );
      default:
        return Result.failure(
          AppErrorCode.authUnknownError,
          message: e.message ?? 'Failed to delete account',
        );
    }
  } catch (e) {
    debugPrint('[DELETE] Unexpected error during account deletion: $e');
    return Result.failure(
      AppErrorCode.unknownError,
      message: "An unexpected error occurred: $e",
    );
  }
}
