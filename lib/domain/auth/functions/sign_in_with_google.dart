// =============================================================================
// SIGN IN WITH GOOGLE
// =============================================================================
//
// This class handles Google OAuth authentication flow.
// It checks if the user is new or existing and returns appropriate data.
//
// For new users: Returns Google profile data to pre-fill registration
// For existing users: Returns UserEntity to proceed directly to home
//
// =============================================================================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../user/entities/user_entity.dart';
import '../models/social_sign_in_result.dart';

class SignInWithGoogle {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  static Future<SocialSignInResult> signIn() async {
    try {
      // 1. Get the GoogleSignIn instance and initialize
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // 2. Create a completer to handle the authentication result
      final Completer<GoogleSignInAccount?> completer =
          Completer<GoogleSignInAccount?>();

      // 3. Listen to authentication events
      late StreamSubscription<GoogleSignInAuthenticationEvent> subscription;
      subscription = googleSignIn.authenticationEvents.listen(
        (GoogleSignInAuthenticationEvent event) {
          switch (event) {
            case GoogleSignInAuthenticationEventSignIn():
              if (!completer.isCompleted) {
                completer.complete(event.user);
              }
              subscription.cancel();
              break;
            case GoogleSignInAuthenticationEventSignOut():
              if (!completer.isCompleted) {
                completer.complete(null);
              }
              subscription.cancel();
              break;
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
          subscription.cancel();
        },
      );

      // 4. Trigger authentication
      if (googleSignIn.supportsAuthenticate()) {
        await googleSignIn.authenticate();
      } else {
        subscription.cancel();
        return SocialSignInResult.failure(
          'Google Sign-In not supported on this platform',
          SocialProvider.google,
        );
      }

      // 5. Wait for the authentication result
      final GoogleSignInAccount? googleUser = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          subscription.cancel();
          return null;
        },
      );

      // User cancelled the sign-in
      if (googleUser == null) {
        return SocialSignInResult.failure(
          'Sign-in cancelled',
          SocialProvider.google,
        );
      }

      // 6. Get authorization for Firebase scopes
      final GoogleSignInClientAuthorization? authorization = await googleUser
          .authorizationClient
          .authorizationForScopes(_scopes);

      if (authorization == null) {
        return SocialSignInResult.failure(
          'Failed to get authorization',
          SocialProvider.google,
        );
      }

      // 7. Get auth headers for token extraction
      final Map<String, String>? headers = await googleUser.authorizationClient
          .authorizationHeaders(_scopes);

      if (headers == null) {
        return SocialSignInResult.failure(
          'Failed to get auth headers',
          SocialProvider.google,
        );
      }

      // 8. Extract access token from headers
      final String? accessToken = headers['Authorization']?.replaceAll(
        'Bearer ',
        '',
      );

      if (accessToken == null) {
        return SocialSignInResult.failure(
          'Failed to get access token',
          SocialProvider.google,
        );
      }

      // 9. For Firebase, we need both access token and ID token
      // Since Google Sign-In v7.1.1 doesn't provide direct ID token access,
      // we'll use the access token for both (Firebase will validate)
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        // Note: In v7.1.1, we might need to make an additional request for ID token
        // For now, trying with access token only
      );

      // 10. Sign in to Firebase with the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return SocialSignInResult.failure(
          'Failed to get user information',
          SocialProvider.google,
        );
      }

      debugPrint(
        '[GOOGLE SIGN-IN] Firebase Auth successful - UID: ${firebaseUser.uid}',
      );
      debugPrint('[GOOGLE SIGN-IN] User email: ${firebaseUser.email}');

      // 11. Check if user exists in Firestore
      final firestore = FirebaseFirestore.instance;
      debugPrint(
        '[GOOGLE SIGN-IN] Checking Firestore document at path: users/${firebaseUser.uid}',
      );

      final userDoc = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      debugPrint('[GOOGLE SIGN-IN] Document exists: ${userDoc.exists}');
      debugPrint(
        '[GOOGLE SIGN-IN] Document has data: ${userDoc.data() != null}',
      );

      if (userDoc.exists && userDoc.data() != null) {
        // Existing user - Load user entity
        final userData = userDoc.data()!;
        debugPrint(
          '[GOOGLE SIGN-IN] EXISTING USER FOUND - Document data: ${userData.keys.toList()}',
        );

        // Check if user is blocked by admin
        final isBlocked = userData['adminblocked'] ?? false;
        if (isBlocked) {
          // Don't sign out here - let UI handle the logout after showing modal
          debugPrint('[GOOGLE SIGN-IN] User is blocked');
          return SocialSignInResult.failure(
            'BLOCKED_USER',
            SocialProvider.google,
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
            debugPrint('[GOOGLE SIGN-IN] FCM token updated successfully');
          } else {
            debugPrint('[GOOGLE SIGN-IN] FCM token skipped for web platform');
          }
        } catch (e) {
          debugPrint(
            '[GOOGLE SIGN-IN] Failed to update FCM token (continuing without it): $e',
          );
        }

        // Return existing user entity
        final userEntity = UserEntity.fromJson({
          ...userData,
          if (fcmToken != null) 'fcmToken': fcmToken,
        });

        debugPrint('[GOOGLE SIGN-IN] Returning existing user result');
        return SocialSignInResult.existingUser(
          userEntity,
          SocialProvider.google,
        );
      } else {
        // New user - Prepare Google data for registration
        debugPrint('[GOOGLE SIGN-IN] NEW USER DETECTED - No document found');
        debugPrint(
          '[GOOGLE SIGN-IN] Keeping user authenticated for profile completion',
        );

        final displayName = googleUser.displayName ?? '';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1
            ? nameParts.skip(1).join(' ')
            : '';

        final googleData = {
          'uid': firebaseUser.uid,
          'email': googleUser.email,
          'displayName': displayName,
          'firstName': firstName,
          'lastName': lastName,
          'photoUrl': googleUser.photoUrl,
          'isSocialSignUp': true,
          'socialProvider': 'google',
        };

        debugPrint(
          '[GOOGLE SIGN-IN] Returning new user result with data: ${googleData.keys.toList()}',
        );
        return SocialSignInResult.newUser(googleData, SocialProvider.google);
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');

      // Handle specific Firebase Auth errors
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            return SocialSignInResult.failure(
              'An account already exists with the same email address but different sign-in credentials.',
              SocialProvider.google,
            );
          case 'invalid-credential':
            return SocialSignInResult.failure(
              'Invalid credentials. Please try again.',
              SocialProvider.google,
            );
          case 'operation-not-allowed':
            return SocialSignInResult.failure(
              'Google sign-in is not enabled.',
              SocialProvider.google,
            );
          case 'user-disabled':
            return SocialSignInResult.failure(
              'This user account has been disabled.',
              SocialProvider.google,
            );
          default:
            return SocialSignInResult.failure(
              'Authentication failed: ${e.message}',
              SocialProvider.google,
            );
        }
      }

      // Handle Google Sign-In specific errors
      if (e is GoogleSignInException) {
        switch (e.code) {
          case GoogleSignInExceptionCode.canceled:
            return SocialSignInResult.failure(
              'Sign-in cancelled',
              SocialProvider.google,
            );
          default:
            return SocialSignInResult.failure(
              'Google Sign-In failed: ${e.description}',
              SocialProvider.google,
            );
        }
      }

      return SocialSignInResult.failure(
        'An unexpected error occurred: $e',
        SocialProvider.google,
      );
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.disconnect();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Check if user is signed in with Google
  static Future<bool> isSignedIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // Try to sign in silently to check if user is already signed in
      try {
        await googleSignIn.attemptLightweightAuthentication();

        // Listen to auth events to check current state
        final completer = Completer<bool>();
        late StreamSubscription<GoogleSignInAuthenticationEvent> subscription;

        subscription = googleSignIn.authenticationEvents.listen(
          (GoogleSignInAuthenticationEvent event) {
            switch (event) {
              case GoogleSignInAuthenticationEventSignIn():
                if (!completer.isCompleted) {
                  completer.complete(true);
                }
                subscription.cancel();
                break;
              case GoogleSignInAuthenticationEventSignOut():
                if (!completer.isCompleted) {
                  completer.complete(false);
                }
                subscription.cancel();
                break;
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            subscription.cancel();
          },
        );

        return await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            subscription.cancel();
            return false;
          },
        );
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
