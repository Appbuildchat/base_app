import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../../core/validators.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../../user/entities/user_entity.dart';

// This class logs in to Firebase Auth using email and password,
// retrieves user information from Firestore and returns it as `Result<UserEntity>`.
// FCM token is automatically updated after successful login.
//
// Usage flow:
// 1. Email/password validation
// 2. Firebase Auth login attempt
// 3. Load user information from Firestore
// 4. Update and save FCM token
//
// Usage example:
// ```dart
// final result = await SignInWithEmail.withEmail('test@email.com', 'password123');
// if (result.isSuccess) {
//   final user = result.data!;
//   // Handle successful login
// } else {
//   // Handle error: result.error and result.message
// }
// ```
class SignInWithEmail {
  static final Logger _logger = Logger();

  static Future<Result<UserEntity>> withEmail(
    String email,
    String password,
  ) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // 1. Email/password validation
    if (Validators.email(email) != null) {
      return Result.failure(
        AppErrorCode.authInvalidEmailFormat,
        message: 'Invalid email format',
      );
    }

    if (Validators.password(password) != null) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Password must be at least 6 characters long',
      );
    }

    try {
      // 2. Firebase Auth login attempt
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return Result.failure(
          AppErrorCode.authUnknownError,
          message: 'Failed to retrieve user after sign in',
        );
      }

      // 3. Query user document from Firestore
      final snapshot = await firestore.collection('users').doc(user.uid).get();

      if (!snapshot.exists) {
        return Result.failure(
          AppErrorCode.backendResourceNotFound,
          message: 'User not found in database',
        );
      }

      // 4. Check currentUser status after login
      final currentUser = FirebaseAuth.instance.currentUser;
      if (kDebugMode) {
        if (currentUser == null) {
          _logger.e('❌ currentUser is null after login!');
        } else {
          _logger.i(
            '✅ currentUser after login: uid=${currentUser.uid}, email=${currentUser.email}',
          );
        }
      }

      final userData = snapshot.data()!;

      // 5. Check if user is blocked by admin
      final isBlocked = userData['adminblocked'] ?? false;
      if (isBlocked) {
        // Don't sign out here - let UI handle the logout after showing modal
        return Result.failure(
          AppErrorCode.authUserDisabled,
          message: 'Account has been suspended by administrator',
        );
      }

      final userEntity = UserEntity.fromJson(userData);
      return Result.success(userEntity);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      }

      // Firebase authentication related error handling
      switch (e.code) {
        case 'user-not-found':
          return Result.failure(
            AppErrorCode.authCredentialsNotFound,
            message: 'No user found for the provided email',
          );
        case 'wrong-password':
          return Result.failure(
            AppErrorCode.authWrongPassword,
            message: 'Incorrect password',
          );
        case 'too-many-requests':
          return Result.failure(
            AppErrorCode.authTooManyRequests,
            message: 'Too many failed attempts. Please try again later.',
          );
        case 'user-disabled':
          return Result.failure(
            AppErrorCode.authUserDisabled,
            message: 'This account has been disabled',
          );
        default:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: e.message ?? 'An unknown auth error occurred',
          );
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.e('Unexpected error during login: $e');
      }
      // Handle unknown exceptions
      return Result.failure(
        AppErrorCode.unknownError,
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}
