// =============================================================================
// SOCIAL SIGN-IN RESULT MODEL
// =============================================================================
//
// This model represents the result of a social sign-in attempt (Google/Apple).
// It helps distinguish between new users who need to complete registration
// and existing users who can proceed directly to the home screen.
//
// =============================================================================

import '../../user/entities/user_entity.dart';

enum SocialProvider { google, apple }

class SocialSignInResult {
  final bool isNewUser;
  final UserEntity? userEntity;
  final Map<String, dynamic>? socialData;
  final SocialProvider? provider;
  final String? error;

  SocialSignInResult({
    required this.isNewUser,
    this.userEntity,
    this.socialData,
    this.provider,
    this.error,
  });

  // Success factory for existing user
  factory SocialSignInResult.existingUser(
    UserEntity user,
    SocialProvider provider,
  ) {
    return SocialSignInResult(
      isNewUser: false,
      userEntity: user,
      provider: provider,
    );
  }

  // Success factory for new user
  factory SocialSignInResult.newUser(
    Map<String, dynamic> data,
    SocialProvider provider,
  ) {
    return SocialSignInResult(
      isNewUser: true,
      socialData: data,
      provider: provider,
    );
  }

  // Error factory
  factory SocialSignInResult.failure(String error, [SocialProvider? provider]) {
    return SocialSignInResult(
      isNewUser: false,
      error: error,
      provider: provider,
    );
  }

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}
