// ============================================================================
// REAUTHENTICATE WITH GOOGLE
// ============================================================================
//
// This function re-authenticates the current user with Google Sign-In.
// This is required for sensitive operations like account deletion.
//
// Usage:
// ```dart
// try {
//   await reauthenticateWithGoogle();
//   // Proceed with sensitive operation
// } catch (e) {
//   // Handle re-authentication failure
// }
// ```
//
// Note: This function requires the user to be already signed in with Google.
// ============================================================================

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> reauthenticateWithGoogle() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw Exception('No user currently signed in');
  }

  debugPrint('[GOOGLE REAUTH] Starting Google re-authentication...');

  try {
    // Initialize Google Sign-In
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();

    // Create a completer to handle the authentication result
    final Completer<GoogleSignInAccount?> completer =
        Completer<GoogleSignInAccount?>();

    // Listen to authentication events
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

    // Trigger authentication
    if (googleSignIn.supportsAuthenticate()) {
      await googleSignIn.authenticate();
    } else {
      subscription.cancel();
      throw Exception('Google Sign-In not supported on this platform');
    }

    // Wait for the authentication result
    final GoogleSignInAccount? googleUser = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        subscription.cancel();
        return null;
      },
    );

    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled or failed');
    }

    debugPrint('[GOOGLE REAUTH] Google user obtained');

    // Get authorization for Firebase scopes
    const List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    final authorization = await googleUser.authorizationClient
        .authorizationForScopes(scopes);

    if (authorization == null) {
      throw Exception('Failed to get Google authorization');
    }

    // Get auth headers for token extraction
    final Map<String, String>? headers = await googleUser.authorizationClient
        .authorizationHeaders(scopes);

    if (headers == null) {
      throw Exception('Failed to get auth headers');
    }

    // Extract access token from Authorization header
    final String? authHeader = headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      throw Exception('Invalid authorization header format');
    }

    final String accessToken = authHeader.substring(
      7,
    ); // Remove "Bearer " prefix

    debugPrint('[GOOGLE REAUTH] Google authentication tokens obtained');

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: null, // ID token not available in this flow
    );

    // Re-authenticate with Firebase
    await currentUser.reauthenticateWithCredential(credential);

    debugPrint('[GOOGLE REAUTH] Google re-authentication successful');
  } catch (e) {
    debugPrint('[GOOGLE REAUTH] Google re-authentication failed: $e');

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-mismatch':
          throw Exception('The Google account does not match the current user');
        case 'user-not-found':
          throw Exception('No Firebase user found for the Google account');
        case 'invalid-credential':
          throw Exception('Invalid Google credentials');
        case 'account-exists-with-different-credential':
          throw Exception(
            'An account already exists with a different credential',
          );
        case 'requires-recent-login':
          throw Exception('Recent login required. Please try again.');
        default:
          throw Exception('Google re-authentication failed: ${e.message}');
      }
    }

    rethrow;
  }
}
