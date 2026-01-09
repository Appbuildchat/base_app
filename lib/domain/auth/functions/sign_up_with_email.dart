// =============================================================================
// SIGN UP WITH EMAIL
// =============================================================================
//
// This function creates an account using Firebase Auth with email/password,
// and stores the user profile in Firestore's `users` collection.
// FCM token is also saved during signup.
//
// Usage:
// 1. Pass required information like email, password, name as arguments
// 2. Email duplication check → Auth account creation → Save to Firestore
// 3. Get FCM token and include it in user information
// 4. Immediately logout to prevent automatic login
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart' as functions;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../core/validators.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../../user/entities/user_entity.dart';
import '../../user/entities/role.dart';

Future<Result<UserEntity>> signUpWithEmail({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  Role? role,
  String? bio,
  String? profileImageUrl,
  String? nickname,
}) async {
  debugPrint(
    '[SIGN UP] Starting: email=$email, firstName=$firstName, lastName=$lastName',
  );

  // 1. Email/password validation
  if (Validators.email(email) != null) {
    debugPrint('[SIGN UP] Invalid email format: $email');
    return Result.failure(
      AppErrorCode.authInvalidEmailFormat,
      message: 'Invalid email format',
    );
  }

  if (Validators.password(password) != null) {
    debugPrint('[SIGN UP] Password validation failed');
    return Result.failure(
      AppErrorCode.validationError,
      message: 'Password must be at least 6 characters long',
    );
  }

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final firebaseFunctions = functions.FirebaseFunctions.instance;

  // 2. Email duplication check via Cloud Function
  try {
    debugPrint('[SIGN UP] Checking email duplication via Cloud Function...');

    final callable = firebaseFunctions.httpsCallable('checkEmailAvailability');
    final result = await callable.call({'email': email.toLowerCase().trim()});

    final data = result.data as Map<String, dynamic>;
    debugPrint('[SIGN UP] Cloud Function response: $data');

    if (!data['success']) {
      debugPrint('[SIGN UP] Cloud Function error: ${data['error']}');
      return Result.failure(
        AppErrorCode.apiError,
        message: 'Could not verify email availability: ${data['error']}',
      );
    }

    if (!data['available']) {
      debugPrint(
        '[SIGN UP] Email already in use (Cloud Function duplicate): $email',
      );
      return Result.failure(
        AppErrorCode.validationError,
        message: data['message'] ?? 'Email is already in use',
      );
    }

    debugPrint('[SIGN UP] Email availability confirmed');
  } on functions.FirebaseFunctionsException catch (e) {
    debugPrint('[SIGN UP] Cloud Function error: ${e.code} - ${e.message}');

    // Fallback: Direct Firestore check when Cloud Function fails
    try {
      debugPrint(
        '[SIGN UP] Fallback: Checking email duplication directly in Firestore...',
      );
      final emailExists = await firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (emailExists.docs.isNotEmpty) {
        debugPrint(
          '[SIGN UP] Email already in use (Firestore duplicate): $email',
        );
        return Result.failure(
          AppErrorCode.validationError,
          message: 'Email is already in use',
        );
      }
      debugPrint('[SIGN UP] Fallback Firestore email duplication check passed');
    } catch (fallbackError) {
      debugPrint('[SIGN UP] Error in fallback Firestore check: $fallbackError');
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Could not verify email availability: $fallbackError',
      );
    }
  }

  // 3. Firebase Auth account creation
  UserCredential userCredential;
  try {
    debugPrint('[SIGN UP] Attempting Firebase Auth account creation...');
    userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint('[SIGN UP] Firebase Auth account creation successful');
  } on FirebaseAuthException catch (e) {
    debugPrint(
      '[SIGN UP] Firebase Auth error occurred: ${e.code}, ${e.message}',
    );
    switch (e.code) {
      case 'weak-password':
        return Result.failure(
          AppErrorCode.validationError,
          message: 'The password provided is too weak.',
        );
      case 'email-already-in-use':
        return Result.failure(
          AppErrorCode.validationError,
          message: 'Email already in use.',
        );
      case 'invalid-email':
        return Result.failure(
          AppErrorCode.authInvalidEmailFormat,
          message: 'Invalid email address.',
        );
      case 'operation-not-allowed':
        return Result.failure(
          AppErrorCode.authOperationNotAllowed,
          message: 'Email sign-up is currently disabled.',
        );
      default:
        return Result.failure(
          AppErrorCode.authUnknownError,
          message: e.message ?? 'Auth error occurred',
        );
    }
  }

  final user = userCredential.user;
  if (user == null) {
    debugPrint('[SIGN UP] FirebaseAuth user is null');
    return Result.failure(
      AppErrorCode.authUnknownError,
      message: 'User creation failed',
    );
  }

  // 4. Save user information to Firestore
  final now = DateTime.now();
  final normalizedEmail = email.toLowerCase().trim();

  // Get FCM token safely with platform check
  String? fcmToken;
  try {
    // Only attempt to get FCM token on mobile platforms
    if (!kIsWeb) {
      fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('[SIGN UP] FCM token retrieved successfully');
    } else {
      debugPrint('[SIGN UP] FCM token skipped for web platform');
    }
  } catch (e) {
    debugPrint('[SIGN UP] Failed to get FCM token (continuing without it): $e');
    fcmToken = null;
  }

  final userEntity = UserEntity(
    userId: user.uid,
    firstName: firstName,
    lastName: lastName,
    email: normalizedEmail,
    role: role ?? Role.admin,
    bio: bio ?? '',
    imageUrl: profileImageUrl ?? '',
    nickname: nickname,
    blockedUsers: const [],
    blockedPosts: const [],
    fcmToken: fcmToken,
    authProvider: 'email', // Set auth provider for email sign-up
    createdAt: now,
    updatedAt: now,
  );

  try {
    debugPrint('[SIGN UP] Attempting to save user information to Firestore...');
    await firestore.collection('users').doc(user.uid).set(userEntity.toJson());
    debugPrint(
      '[SIGN UP] User information saved successfully (userId: ${user.uid})',
    );
  } catch (e) {
    debugPrint('[SIGN UP] Firestore save failed: $e');
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: 'Failed to save user profile: $e',
    );
  }

  // 5. Keep user logged in after successful sign-up
  debugPrint('[SIGN UP] User remains logged in after account creation');

  debugPrint('[SIGN UP] Sign up completed successfully');
  return Result.success(userEntity);
}
