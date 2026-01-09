// =============================================================================
// SIGN IN SCREEN
// =============================================================================
//
// Screen where users can log in by entering their email and password.
// Includes Firebase Auth authentication and Firestore user info loading.
//
// Usage:
// 1. Enter email/password and click login button
// 2. Execute `SignInWithEmail.withEmail()`
// 3. Navigate to main screen (/post/list) on successful login
// 4. Display error message on failure
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../../../core/validators.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/modern_toast.dart';
import '../../../../core/app_error_code.dart';
import '../../functions/sign_in_with_email.dart';
import '../../functions/sign_in_with_google.dart';
import '../../functions/sign_in_with_apple.dart';
import '../../functions/check_user_blocked_by_email.dart';
import '../../functions/fetch_admin_emails.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // ============================================================================
  // State and controller declarations
  // ============================================================================

  final _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ============================================================================
  // Login handling functions
  // ============================================================================

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      _logger.d('[GOOGLE_SIGN_IN] Starting Google sign-in...');
      final result = await SignInWithGoogle.signIn();

      if (!mounted) return;

      if (result.isFailure) {
        _logger.e('[GOOGLE_SIGN_IN] Sign-in failed: ${result.error}');
        // Check if user is blocked
        if (result.error?.contains('BLOCKED_USER') == true) {
          _logger.w(
            '[GOOGLE_SIGN_IN] User is blocked, signing out and showing modal...',
          );
          setState(() => _isLoading = false);
          // Sign out the user before showing modal
          await FirebaseAuth.instance.signOut();
          await _showBlockedModal();
          _logger.d(
            '[GOOGLE_SIGN_IN] Blocked modal closed, staying on sign-in screen',
          );
          return;
        }

        _logger.e('[GOOGLE_SIGN_IN] Regular error, showing toast');
        ModernToast.showError(context, result.error ?? 'Google sign-in failed');
        setState(() => _isLoading = false);
        return;
      }

      if (result.isNewUser) {
        _logger.d('[GOOGLE_SIGN_IN] New user, navigating to social sign-up');
        // Navigate to social sign-up screen with social data
        context.go(
          '/auth/social-sign-up',
          extra: {
            'socialData': result.socialData,
            'provider': result.provider?.name,
          },
        );
      } else {
        _logger.d(
          '[GOOGLE_SIGN_IN] Existing user, showing delay then navigating to home',
        );
        // Existing user - show loading for 3 seconds then go to home
        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) return;
        _logger.d('[GOOGLE_SIGN_IN] Navigating to home');
        context.go('/home');
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;

      _logger.d('[GOOGLE_SIGN_IN] Unexpected exception: $e');
      setState(() => _isLoading = false);
      ModernToast.showError(context, 'An unexpected error occurred');
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      _logger.d('[APPLE_SIGN_IN] Starting Apple sign-in...');
      final result = await AppleSignInHandler.signIn();

      if (!mounted) return;

      if (result.isFailure) {
        _logger.d('[APPLE_SIGN_IN] Sign-in failed: ${result.error}');
        // Check if user is blocked
        if (result.error?.contains('BLOCKED_USER') == true) {
          _logger.d(
            '[APPLE_SIGN_IN] User is blocked, signing out and showing modal...',
          );
          setState(() => _isLoading = false);
          // Sign out the user before showing modal
          await FirebaseAuth.instance.signOut();
          await _showBlockedModal();
          _logger.d(
            '[APPLE_SIGN_IN] Blocked modal closed, staying on sign-in screen',
          );
          return;
        }

        _logger.d('[APPLE_SIGN_IN] Regular error, showing toast');
        ModernToast.showError(context, result.error ?? 'Apple sign-in failed');
        setState(() => _isLoading = false);
        return;
      }

      if (result.isNewUser) {
        _logger.d('[APPLE_SIGN_IN] New user, navigating to social sign-up');
        // Navigate to social sign-up screen with Apple data
        context.go(
          '/auth/social-sign-up',
          extra: {'socialData': result.socialData, 'provider': 'apple'},
        );
      } else {
        _logger.d(
          '[APPLE_SIGN_IN] Existing user, showing delay then navigating to home',
        );
        // Existing user - show loading for 3 seconds then go to home
        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) return;
        _logger.d('[APPLE_SIGN_IN] Navigating to home');
        context.go('/home');
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;

      _logger.d('[APPLE_SIGN_IN] Unexpected exception: $e');
      setState(() => _isLoading = false);
      ModernToast.showError(context, 'An unexpected error occurred');
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      _logger.d('[SIGN_IN] Checking if user is blocked before login...');

      // First check if user is blocked by email
      final blockCheckResult = await checkUserBlockedByEmail(
        _emailController.text.trim(),
      );

      if (blockCheckResult.isSuccess && blockCheckResult.data == true) {
        // User is blocked, show modal and stop here
        _logger.d('[SIGN_IN] User is blocked, showing modal...');
        setState(() => _isLoading = false);
        await _showBlockedModal();
        _logger.d('[SIGN_IN] Blocked modal closed, staying on sign-in screen');
        return;
      }

      _logger.d(
        '[SIGN_IN] User is not blocked, proceeding with email login...',
      );
      final result = await SignInWithEmail.withEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        _logger.d('[SIGN_IN] Email login successful, starting delay...');

        // Show loading overlay for 3 seconds before navigating
        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) return;
        _logger.d('[SIGN_IN] Navigating to home screen...');

        // Navigate to home screen after 3 second delay
        context.go('/home');

        // Stop loading after navigation
        if (mounted) {
          setState(() => _isLoading = false);
        }
      } else {
        // Handle error using AppErrorCode
        setState(() => _isLoading = false);
        _logger.d(
          '[SIGN_IN] Login failed: ${result.error?.code} - ${result.message}',
        );

        // Check if user is blocked
        if (result.error == AppErrorCode.authUserDisabled) {
          _logger.d(
            '[SIGN_IN] User is blocked, signing out and showing modal...',
          );
          // Sign out the user before showing modal
          await FirebaseAuth.instance.signOut();
          await _showBlockedModal();
          _logger.d(
            '[SIGN_IN] Blocked modal closed, staying on sign-in screen',
          );
          return;
        }

        _logger.d('[SIGN_IN] Regular login error, showing snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: ${result.message ?? result.error?.message ?? "Unknown error"}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Stop loading immediately on unexpected error
      setState(() => _isLoading = false);
      _logger.d('[SIGN_IN] Unexpected exception caught: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // ============================================================================
  // UI composition
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: AppCommonColors.white.withValues(alpha: 0.0),
          foregroundColor: AppColors.text,
          title: null,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.v40,

                  // Header animation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: AppTypography.headline1)
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideX(begin: -0.2, end: 0, duration: 800.ms),
                      AppSpacing.v8,
                      Text(
                            'Enter your email and password to continue',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.secondary.withValues(alpha: 0.7),
                            ),
                          )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 800.ms)
                          .slideX(begin: -0.2, end: 0, duration: 800.ms),
                    ],
                  ),

                  AppSpacing.v48,

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email input
                        ModernTextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              validator: Validators.email,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.secondary,
                              ),
                            )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v20,

                        // Password input
                        ModernTextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              validator: Validators.password,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.secondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.secondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            )
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push('/auth/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.s,
                              ),
                            ),
                            child: Text(
                              'Forgot password?',
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.primary,
                                fontWeight: AppFontWeights.semiBold,
                              ),
                            ),
                          ),
                        ).animate(delay: 800.ms).fadeIn(duration: 600.ms),

                        AppSpacing.v32,

                        // Login button
                        SizedBox(
                              width: double.infinity,
                              child: ModernButton(
                                text: 'Log in',
                                onPressed: _signIn,
                                isLoading: _isLoading,
                                type: ModernButtonType.primary,
                                height: AppDimensions.buttonHeight,
                              ),
                            )
                            .animate(delay: 1000.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0, duration: 800.ms),

                        AppSpacing.v24,

                        // Divider with "OR"
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: AppDimensions.dividerThickness,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.l,
                              ),
                              child: Text(
                                'OR',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: AppFontWeights.semiBold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: AppDimensions.dividerThickness,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 1100.ms).fadeIn(duration: 600.ms),

                        AppSpacing.v24,

                        // Google Sign-In Button
                        SizedBox(
                              width: double.infinity,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppCommonColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  onTap: _handleGoogleSignIn,
                                  borderRadius: BorderRadius.circular(16),
                                  child: SvgPicture.asset(
                                    'assets/android_light_sq_ctn.svg',
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                            )
                            .animate(delay: 1200.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0, duration: 800.ms),

                        // Apple Sign-In Button (all platforms)
                        AppSpacing.v16,
                        SizedBox(
                              width: double.infinity,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppCommonColors.black,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppShadows.primaryShadow(
                                    AppCommonColors.black,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: _handleAppleSignIn,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      'assets/apple_dark_rd_ctn.svg',
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .animate(delay: 1600.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.4, end: 0, duration: 800.ms),
                      ],
                    ),
                  ),

                  AppSpacing.v60,

                  // Bottom sign up link
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.secondary.withValues(alpha: 0.8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/auth/sign-up'),
                            child: Text(
                              'Sign up',
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.primary,
                                fontWeight: AppFontWeights.semiBold,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate(delay: 1200.ms)
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.2, end: 0, duration: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // Blocked User Modal
  // ============================================================================

  Future<void> _showBlockedModal() async {
    _logger.d('[BLOCKED_MODAL] Showing blocked user modal...');

    // Fetch admin emails
    final adminEmailsResult = await fetchAdminEmails();
    final adminEmails = adminEmailsResult.isSuccess
        ? adminEmailsResult.data!
        : <String>[];

    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: AppDimensions.iconL),
            AppSpacing.h8,
            const Text('Account Blocked'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You have been blocked by the administrator. Please contact one of the admins below:',
            ),
            AppSpacing.v16,
            if (adminEmails.isNotEmpty) ...[
              const Text(
                'Admin Contacts:',
                style: TextStyle(fontWeight: AppFontWeights.semiBold),
              ),
              AppSpacing.v8,
              ...adminEmails.map(
                (email) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      AppSpacing.h8,
                      Expanded(
                        child: SelectableText(
                          email,
                          style: TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'No admin contacts available at the moment.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _logger.d('[BLOCKED_MODAL] User clicked Close button');
              Navigator.of(context).pop();
              _logger.d(
                '[BLOCKED_MODAL] Modal closed, staying on sign-in screen',
              );
            },
            child: const Text('Close'),
          ),
        ],
      ),
    ).then((_) {
      _logger.d(
        '[BLOCKED_MODAL] Modal dialog completed, user should stay on sign-in screen',
      );
    });
  }

  // ============================================================================
  // Resource disposal
  // ============================================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
