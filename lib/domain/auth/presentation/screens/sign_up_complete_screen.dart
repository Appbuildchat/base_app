import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../functions/sign_up_with_email.dart';
import '../../../user/entities/role.dart';
import '../../../user/entities/user_entity.dart';

class SignUpCompleteScreen extends StatefulWidget {
  final Map<String, dynamic> signUpData;

  const SignUpCompleteScreen({super.key, required this.signUpData});

  @override
  State<SignUpCompleteScreen> createState() => _SignUpCompleteScreenState();
}

class _SignUpCompleteScreenState extends State<SignUpCompleteScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-submit on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _completeSignUp();
    });
  }

  Future<void> _completeSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isSocialSignUp = widget.signUpData['isSocialSignUp'] == true;
      final isGoogleSignUp =
          widget.signUpData['isGoogleSignUp'] == true; // Legacy support

      debugPrint('[SIGN UP COMPLETE] Starting sign up completion...');
      debugPrint('[SIGN UP COMPLETE] Is social sign up: $isSocialSignUp');
      debugPrint(
        '[SIGN UP COMPLETE] Is Google sign up (legacy): $isGoogleSignUp',
      );
      debugPrint(
        '[SIGN UP COMPLETE] Sign up data keys: ${widget.signUpData.keys.toList()}',
      );

      if (isSocialSignUp || isGoogleSignUp) {
        debugPrint('[SIGN UP COMPLETE] Completing social sign up...');
        await _completeSocialSignUp();
        debugPrint('[SIGN UP COMPLETE] Social sign up completed successfully');
      } else {
        debugPrint('[SIGN UP COMPLETE] Completing email sign up...');
        await _completeEmailSignUp();
        debugPrint('[SIGN UP COMPLETE] Email sign up completed successfully');
      }

      if (!mounted) return;

      // Navigate to home screen on success
      debugPrint('[SIGN UP COMPLETE] Navigating to home screen');
      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      // Show error and allow retry
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: $e'),
          backgroundColor: AppColors.accent,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _completeSignUp,
            textColor: AppCommonColors.white,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeEmailSignUp() async {
    // Extract data from signUpData map
    final email = widget.signUpData['email'] as String;
    final password = widget.signUpData['password'] as String;
    final firstName = widget.signUpData['firstName'] as String;
    final lastName = widget.signUpData['lastName'] as String;
    final role = widget.signUpData['role'] as Role;
    final nickname = widget.signUpData['nickname'] as String?;

    // Perform email sign up
    await signUpWithEmail(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
      nickname: nickname,
    );
  }

  Future<void> _completeSocialSignUp() async {
    final socialProvider = widget.signUpData['socialProvider'] as String?;
    debugPrint(
      '[SOCIAL SIGN UP] Starting social user document creation for $socialProvider',
    );

    // Use current Firebase user UID (user is already authenticated)
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }

    // Use current user's UID (this is always reliable since user is authenticated)
    final socialUid = currentUser.uid;
    debugPrint('[SOCIAL SIGN UP] Using current Firebase user UID: $socialUid');

    // Also log what was passed in the data for debugging
    final passedSocialUid = widget.signUpData['socialUid'] as String?;
    debugPrint(
      '[SOCIAL SIGN UP] Passed social UID from form: $passedSocialUid',
    );

    if (passedSocialUid != null && passedSocialUid != socialUid) {
      debugPrint(
        '[SOCIAL SIGN UP] WARNING: Passed UID ($passedSocialUid) differs from current user UID ($socialUid). Using current user UID.',
      );
    }

    // Extract data from signUpData map
    final email = widget.signUpData['email'] as String;
    final firstName = widget.signUpData['firstName'] as String;
    final lastName = widget.signUpData['lastName'] as String;
    final role = widget.signUpData['role'] as Role;
    final nickname = widget.signUpData['nickname'] as String?;
    final profileImageUrl = widget.signUpData['profileImageUrl'] as String?;

    final firestore = FirebaseFirestore.instance;

    // Get FCM token safely with platform check
    String? fcmToken;
    try {
      // Only attempt to get FCM token on mobile platforms
      if (!kIsWeb) {
        fcmToken = await FirebaseMessaging.instance.getToken();
        debugPrint('[SOCIAL SIGN UP] FCM token obtained successfully');
      } else {
        debugPrint('[SOCIAL SIGN UP] FCM token skipped for web platform');
      }
    } catch (e) {
      debugPrint(
        '[SOCIAL SIGN UP] Failed to get FCM token (continuing without it): $e',
      );
      fcmToken = null;
    }

    // Determine auth provider from social provider
    String authProvider = 'unknown';
    if (socialProvider != null) {
      switch (socialProvider.toLowerCase()) {
        case 'google':
          authProvider = 'google';
          break;
        case 'apple':
          authProvider = 'apple';
          break;
        default:
          authProvider = 'unknown';
      }
    }
    debugPrint('[SOCIAL SIGN UP] Auth provider determined: $authProvider');

    // Create user entity
    final now = DateTime.now();
    final userEntity = UserEntity(
      userId: socialUid,
      firstName: firstName,
      lastName: lastName,
      email: email.toLowerCase().trim(),
      role: role,
      bio: '',
      imageUrl: profileImageUrl ?? '',
      nickname: nickname,
      blockedUsers: const [],
      blockedPosts: const [],
      fcmToken: fcmToken,
      authProvider: authProvider, // Set auth provider for social sign-up
      createdAt: now,
      updatedAt: now,
    );

    try {
      debugPrint('[SOCIAL SIGN UP] Saving user document to Firestore...');
      debugPrint('[SOCIAL SIGN UP] Document ID: $socialUid');
      debugPrint('[SOCIAL SIGN UP] User Entity: ${userEntity.toJson()}');
      debugPrint(
        '[SOCIAL SIGN UP] Current user authenticated: ${FirebaseAuth.instance.currentUser != null}',
      );
      debugPrint(
        '[SOCIAL SIGN UP] Current user UID: ${FirebaseAuth.instance.currentUser?.uid}',
      );

      await firestore
          .collection('users')
          .doc(socialUid)
          .set(userEntity.toJson());

      // Verify the document was saved
      final verifyDoc = await firestore
          .collection('users')
          .doc(socialUid)
          .get();
      debugPrint(
        '[SOCIAL SIGN UP] Document verification - exists: ${verifyDoc.exists}',
      );
      if (verifyDoc.exists) {
        debugPrint(
          '[SOCIAL SIGN UP] Document data keys: ${verifyDoc.data()?.keys.toList()}',
        );
      }

      debugPrint(
        '[SOCIAL SIGN UP] User document created successfully (userId: $socialUid)',
      );
      debugPrint(
        '[SOCIAL SIGN UP] User remains authenticated, ready for home navigation',
      );
    } catch (e) {
      debugPrint('[SOCIAL SIGN UP] Firestore save failed: $e');
      debugPrint('[SOCIAL SIGN UP] Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        debugPrint('[SOCIAL SIGN UP] Firebase error code: ${e.code}');
        debugPrint('[SOCIAL SIGN UP] Firebase error message: ${e.message}');
      }
      throw Exception('Failed to save user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.text,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                AppColors.background.withValues(alpha: 0.8),
                AppCommonColors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Success Icon
                        Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isLoading
                                    ? Icons.hourglass_empty
                                    : Icons.check_circle,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(duration: 400.ms),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                              _isLoading
                                  ? 'Creating Your Account'
                                  : 'Almost Done!',
                              style: AppTypography.headline1,
                              textAlign: TextAlign.center,
                            )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                              _isLoading
                                  ? 'Please wait while we set up your account...'
                                  : 'Your account is being created. You\'ll be redirected to the home screen shortly.',
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        const SizedBox(height: 48),

                        // Loading indicator or retry button
                        if (_isLoading)
                          CircularProgressIndicator(color: AppColors.primary)
                              .animate(delay: 600.ms)
                              .fadeIn(duration: 400.ms)
                              .scale(duration: 400.ms)
                        else if (!_isLoading)
                          SizedBox(
                                width: double.infinity,
                                child: ModernButton(
                                  text: 'Retry Sign Up',
                                  onPressed: _completeSignUp,
                                  type: ModernButtonType.primary,
                                  height: 56,
                                ),
                              )
                              .animate(delay: 600.ms)
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.3, end: 0, duration: 600.ms),

                        const SizedBox(height: 24),

                        // Back to sign up link
                        TextButton(
                          onPressed: () => context.go('/auth/sign-up'),
                          child: Text(
                            'Back to Sign Up',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.primary,
                              fontWeight: AppFontWeights.semiBold,
                            ),
                          ),
                        ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
