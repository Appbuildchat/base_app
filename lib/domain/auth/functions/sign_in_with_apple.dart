// =============================================================================
// SIGN IN WITH APPLE
// =============================================================================
//
// This class handles Apple ID authentication flow.
// It checks if the user is new or existing and returns appropriate data.
//
// For new users: Returns Apple profile data to pre-fill registration
// For existing users: Returns UserEntity to proceed directly to home
//
// =============================================================================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../user/entities/user_entity.dart';
import '../models/social_sign_in_result.dart';

class AppleSignInHandler {
  static Future<SocialSignInResult> signIn() async {
    try {
      debugPrint('[APPLE SIGN-IN] Starting Apple Sign-In process');

      // 1. Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        debugPrint(
          '[APPLE SIGN-IN] Apple Sign-In not available on this device',
        );
        return SocialSignInResult.failure(
          'Apple Sign-In is not available on this device',
          SocialProvider.apple,
        );
      }

      // 2. Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: null, // You can add a nonce for extra security if needed
        state: null, // You can add state for extra security if needed
      );

      debugPrint('[APPLE SIGN-IN] Apple credential obtained');
      debugPrint('[APPLE SIGN-IN] User ID: ${appleCredential.userIdentifier}');
      debugPrint('[APPLE SIGN-IN] Email: ${appleCredential.email}');

      // 3. Create Firebase credential from Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 4. Sign in to Firebase with the Apple credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return SocialSignInResult.failure(
          'Failed to get user information',
          SocialProvider.apple,
        );
      }

      debugPrint(
        '[APPLE SIGN-IN] Firebase Auth successful - UID: ${firebaseUser.uid}',
      );
      debugPrint('[APPLE SIGN-IN] User email: ${firebaseUser.email}');

      // 5. Check if user exists in Firestore
      final firestore = FirebaseFirestore.instance;
      debugPrint(
        '[APPLE SIGN-IN] Checking Firestore document at path: users/${firebaseUser.uid}',
      );

      final userDoc = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      debugPrint('[APPLE SIGN-IN] Document exists: ${userDoc.exists}');
      debugPrint(
        '[APPLE SIGN-IN] Document has data: ${userDoc.data() != null}',
      );

      if (userDoc.exists && userDoc.data() != null) {
        // Existing user - Load user entity
        final userData = userDoc.data()!;
        debugPrint(
          '[APPLE SIGN-IN] EXISTING USER FOUND - Document data: ${userData.keys.toList()}',
        );

        // Check if user is blocked by admin
        final isBlocked = userData['adminblocked'] ?? false;
        if (isBlocked) {
          // Don't sign out here - let UI handle the logout after showing modal
          debugPrint('[APPLE SIGN-IN] User is blocked');
          return SocialSignInResult.failure(
            'BLOCKED_USER',
            SocialProvider.apple,
          );
        }

        // Update FCM token if available
        String? fcmToken;
        try {
          // Only attempt to get FCM token on mobile platforms
          if (!kIsWeb) {
            fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              await firestore.collection('users').doc(firebaseUser.uid).update({
                'fcmToken': fcmToken,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
            debugPrint('[APPLE SIGN-IN] FCM token updated successfully');
          } else {
            debugPrint('[APPLE SIGN-IN] FCM token skipped for web platform');
          }
        } catch (e) {
          debugPrint(
            '[APPLE SIGN-IN] Failed to update FCM token (continuing without it): $e',
          );
        }

        // Return existing user entity
        final userEntity = UserEntity.fromJson({
          ...userData,
          if (fcmToken != null) 'fcmToken': fcmToken,
        });

        debugPrint('[APPLE SIGN-IN] Returning existing user result');
        return SocialSignInResult.existingUser(
          userEntity,
          SocialProvider.apple,
        );
      } else {
        // New user - Prepare Apple data for registration
        debugPrint('[APPLE SIGN-IN] NEW USER DETECTED - No document found');
        debugPrint(
          '[APPLE SIGN-IN] Keeping user authenticated for profile completion',
        );

        // Extract name information from Apple credential
        String firstName = '';
        String lastName = '';
        String displayName = '';

        if (appleCredential.givenName != null &&
            appleCredential.familyName != null) {
          firstName = appleCredential.givenName!;
          lastName = appleCredential.familyName!;
          displayName = '$firstName $lastName';
        } else {
          // Apple doesn't always provide names (only on first sign-in)
          // Use email or fallback to empty strings
          displayName = appleCredential.email ?? '';
        }

        final appleData = {
          'uid': firebaseUser.uid,
          'email': appleCredential.email ?? firebaseUser.email ?? '',
          'displayName': displayName,
          'firstName': firstName,
          'lastName': lastName,
          'photoUrl': null, // Apple doesn't provide profile photos
          'isSocialSignUp': true,
          'socialProvider': 'apple',
        };

        debugPrint(
          '[APPLE SIGN-IN] Returning new user result with data: ${appleData.keys.toList()}',
        );
        return SocialSignInResult.newUser(appleData, SocialProvider.apple);
      }
    } catch (e) {
      debugPrint('[APPLE SIGN-IN] Apple Sign-In Error: $e');

      // Handle specific Apple Sign-In errors
      if (e is SignInWithAppleAuthorizationException) {
        switch (e.code) {
          case AuthorizationErrorCode.canceled:
            return SocialSignInResult.failure(
              'Sign-in cancelled',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.failed:
            return SocialSignInResult.failure(
              'Apple Sign-In failed',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.invalidResponse:
            return SocialSignInResult.failure(
              'Invalid response from Apple',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.notHandled:
            return SocialSignInResult.failure(
              'Apple Sign-In not handled',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.notInteractive:
            return SocialSignInResult.failure(
              'Apple Sign-In requires user interaction',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.credentialExport:
            return SocialSignInResult.failure(
              'Apple credential export failed',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.credentialImport:
            return SocialSignInResult.failure(
              'Apple credential import failed',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.matchedExcludedCredential:
            return SocialSignInResult.failure(
              'Apple matched excluded credential',
              SocialProvider.apple,
            );
          case AuthorizationErrorCode.unknown:
            return SocialSignInResult.failure(
              'Unknown Apple Sign-In error',
              SocialProvider.apple,
            );
        }
      }

      // Handle Firebase Auth errors
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            return SocialSignInResult.failure(
              'An account already exists with the same email address but different sign-in credentials.',
              SocialProvider.apple,
            );
          case 'invalid-credential':
            return SocialSignInResult.failure(
              'Invalid credentials. Please try again.',
              SocialProvider.apple,
            );
          case 'operation-not-allowed':
            return SocialSignInResult.failure(
              'Apple sign-in is not enabled.',
              SocialProvider.apple,
            );
          case 'user-disabled':
            return SocialSignInResult.failure(
              'This user account has been disabled.',
              SocialProvider.apple,
            );
          default:
            return SocialSignInResult.failure(
              'Authentication failed: ${e.message}',
              SocialProvider.apple,
            );
        }
      }

      return SocialSignInResult.failure(
        'An unexpected error occurred: $e',
        SocialProvider.apple,
      );
    }
  }

  /// Sign out from Apple (Firebase only, Apple doesn't have explicit sign out)
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('[APPLE SIGN-IN] Error signing out: $e');
    }
  }

  /// Check if Apple Sign-In is available on this device
  static Future<bool> isAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      debugPrint('[APPLE SIGN-IN] Error checking availability: $e');
      return false;
    }
  }
}
