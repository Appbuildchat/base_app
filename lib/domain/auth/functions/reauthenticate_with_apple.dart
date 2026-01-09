// ============================================================================
// REAUTHENTICATE WITH APPLE
// ============================================================================
//
// This function re-authenticates the current user with Apple Sign-In.
// This is required for sensitive operations like account deletion.
//
// Usage:
// ```dart
// try {
//   await reauthenticateWithApple();
//   // Proceed with sensitive operation
// } catch (e) {
//   // Handle re-authentication failure
// }
// ```
//
// Note: This function requires the user to be already signed in with Apple.
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

Future<Result<void>> reauthenticateWithApple() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return Result.failure(
      AppErrorCode.authNotLoggedIn,
      message: 'No user currently signed in',
    );
  }

  debugPrint('[APPLE REAUTH] Starting Apple re-authentication...');

  try {
    // Check if Apple Sign-In is available
    if (!await SignInWithApple.isAvailable()) {
      return Result.failure(
        AppErrorCode.authOperationNotAllowed,
        message: 'Apple Sign-In is not available on this device',
      );
    }

    debugPrint('[APPLE REAUTH] Apple Sign-In is available');

    // Request Apple ID credential for re-authentication
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    debugPrint('[APPLE REAUTH] Apple credential obtained');

    // Create Firebase credential from Apple credential
    final credential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    // Re-authenticate with Firebase
    await currentUser.reauthenticateWithCredential(credential);

    debugPrint('[APPLE REAUTH] Apple re-authentication successful');

    return Result.success(null);
  } catch (e) {
    debugPrint('[APPLE REAUTH] Apple re-authentication failed: $e');

    if (e is SignInWithAppleAuthorizationException) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return Result.failure(
            AppErrorCode.authProcessAborted,
            message: 'Apple Sign-In was cancelled',
          );
        case AuthorizationErrorCode.failed:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Apple Sign-In failed',
          );
        case AuthorizationErrorCode.invalidResponse:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Invalid response from Apple',
          );
        case AuthorizationErrorCode.notHandled:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Apple Sign-In not handled',
          );
        case AuthorizationErrorCode.notInteractive:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Apple Sign-In requires user interaction',
          );
        case AuthorizationErrorCode.credentialExport:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Apple credential export failed',
          );
        case AuthorizationErrorCode.credentialImport:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Apple credential import failed',
          );
        case AuthorizationErrorCode.matchedExcludedCredential:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Apple matched excluded credential',
          );
        case AuthorizationErrorCode.unknown:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Unknown Apple Sign-In error',
          );
      }
    }

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-mismatch':
          return Result.failure(
            AppErrorCode.authCredentialsNotFound,
            message: 'The Apple account does not match the current user',
          );
        case 'user-not-found':
          return Result.failure(
            AppErrorCode.authCredentialsNotFound,
            message: 'No Firebase user found for the Apple account',
          );
        case 'invalid-credential':
          return Result.failure(
            AppErrorCode.authCredentialsNotFound,
            message: 'Invalid Apple credentials',
          );
        case 'account-exists-with-different-credential':
          return Result.failure(
            AppErrorCode.authOperationNotAllowed,
            message: 'An account already exists with a different credential',
          );
        default:
          return Result.failure(
            AppErrorCode.authUnknownError,
            message: 'Apple re-authentication failed: ${e.message}',
          );
      }
    }

    return Result.failure(
      AppErrorCode.authUnknownError,
      message: 'Unknown error during Apple re-authentication',
    );
  }
}
