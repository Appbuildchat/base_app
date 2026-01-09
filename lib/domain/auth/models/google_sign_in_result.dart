// =============================================================================
// GOOGLE SIGN-IN RESULT MODEL
// =============================================================================
//
// This model represents the result of a Google Sign-In attempt.
// It helps distinguish between new users who need to complete registration
// and existing users who can proceed directly to the home screen.
//
// =============================================================================

import '../../user/entities/user_entity.dart';

class GoogleSignInResult {
  final bool isNewUser;
  final UserEntity? userEntity;
  final Map<String, dynamic>? googleData;
  final String? error;

  GoogleSignInResult({
    required this.isNewUser,
    this.userEntity,
    this.googleData,
    this.error,
  });

  // Success factory for existing user
  factory GoogleSignInResult.existingUser(UserEntity user) {
    return GoogleSignInResult(isNewUser: false, userEntity: user);
  }

  // Success factory for new user
  factory GoogleSignInResult.newUser(Map<String, dynamic> data) {
    return GoogleSignInResult(isNewUser: true, googleData: data);
  }

  // Error factory
  factory GoogleSignInResult.failure(String error) {
    return GoogleSignInResult(isNewUser: false, error: error);
  }

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}
