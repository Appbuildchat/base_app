import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth/presentation/screens/splash_screen.dart';
import '../../domain/auth/presentation/screens/onboarding_screen.dart';
import '../../domain/auth/presentation/screens/sign_in_and_up_screen.dart';
import '../../domain/auth/presentation/screens/sign_in_screen.dart';
import '../../domain/auth/presentation/screens/sign_up_screen.dart';
import '../../domain/auth/presentation/screens/social_sign_up_screen.dart';
import '../../domain/auth/models/social_sign_in_result.dart';
import '../../domain/auth/presentation/screens/forgot_password_screen.dart';
import '../../domain/auth/presentation/screens/next_sign_up_tnc_screen.dart';
import '../../domain/auth/presentation/screens/sign_up_complete_screen.dart';
import '../../domain/settings/presentation/screens/settings_screen.dart';
import '../../domain/settings/presentation/screens/change_password_screen.dart';
import '../../domain/settings/presentation/screens/change_username_screen.dart';
import '../../domain/settings/presentation/screens/change_bio_screen.dart';
import '../../domain/settings/presentation/screens/change_nickname_screen.dart';
import '../../domain/settings/presentation/screens/change_phone_screen.dart';
import '../../domain/feedback/presentation/screens/feedback_screen.dart';
import '../../domain/admin/presentation/screens/feedback_list_screen.dart';
import 'app_router.dart';

class GeneralRoutes {
  static List<GoRoute> get routes => [
    // Splash Screen (Initial screen)
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          CustomPageTransition.fadeTransition(const SplashScreen(), state),
    ),

    // Onboarding Screen
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          CustomPageTransition.fadeTransition(const OnboardingScreen(), state),
    ),

    // Welcome/Landing Screen
    GoRoute(
      path: '/auth/sign-in-and-up',
      pageBuilder: (context, state) => CustomPageTransition.scaleTransition(
        const SignInAndUpScreen(),
        state,
      ),
    ),

    // Sign In Screen
    GoRoute(
      path: '/auth/sign-in',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const SignInScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Sign Up Screen
    GoRoute(
      path: '/auth/sign-up',
      pageBuilder: (context, state) {
        final googleData = state.extra as Map<String, dynamic>?;
        return CustomPageTransition.slideTransition(
          SignUpScreen(googleData: googleData),
          state,
          begin: const Offset(1.0, 0.0),
        );
      },
    ),

    // Social Sign Up Screen (Google/Apple)
    GoRoute(
      path: '/auth/social-sign-up',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final socialData = data?['socialData'] as Map<String, dynamic>?;
        final providerName = data?['provider'] as String?;

        SocialProvider? provider;
        if (providerName == 'google') {
          provider = SocialProvider.google;
        } else if (providerName == 'apple') {
          provider = SocialProvider.apple;
        }

        return CustomPageTransition.slideTransition(
          SocialSignUpScreen(socialData: socialData, provider: provider),
          state,
          begin: const Offset(1.0, 0.0),
        );
      },
    ),

    // Forgot Password Screen
    GoRoute(
      path: '/auth/forgot-password',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const ForgotPasswordScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Sign Up Terms & Conditions Screen
    GoRoute(
      path: '/auth/sign-up-tnc',
      pageBuilder: (context, state) {
        final signUpData = state.extra as Map<String, dynamic>?;
        return CustomPageTransition.slideTransition(
          NextSignUpTncScreen(signUpData: signUpData ?? {}),
          state,
          begin: const Offset(1.0, 0.0),
        );
      },
    ),

    // Sign Up Complete Screen
    GoRoute(
      path: '/auth/sign-up-complete',
      pageBuilder: (context, state) {
        final signUpData = state.extra as Map<String, dynamic>?;
        return CustomPageTransition.slideTransition(
          SignUpCompleteScreen(signUpData: signUpData ?? {}),
          state,
          begin: const Offset(1.0, 0.0),
        );
      },
    ),

    // Settings Screen
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const SettingsScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Change Password Screen
    GoRoute(
      path: '/settings/change-password',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const ChangePasswordScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Change Username Screen
    GoRoute(
      path: '/settings/change-username',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const ChangeUsernameScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Change Bio Screen
    GoRoute(
      path: '/settings/change-bio',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const ChangeBioScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Change Nickname Screen
    GoRoute(
      path: '/settings/change-nickname',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const ChangeNicknameScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Change Phone Screen
    GoRoute(
      path: '/settings/change-phone',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const ChangePhoneScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Feedback Screen (User submission)
    GoRoute(
      path: '/settings/feedback',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const FeedbackScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),

    // Feedback List Screen (Admin only)
    GoRoute(
      path: '/admin/feedback-list',
      pageBuilder: (context, state) => CustomPageTransition.slideTransition(
        const FeedbackListScreen(),
        state,
        begin: const Offset(1.0, 0.0),
      ),
    ),
  ];
}
