// =============================================================================
// SIGN IN AND UP SCREEN (Entry Screen)
// =============================================================================
//
// 이 Screen은 앱 실행 시 처음 보여지는 Entry Screen으로,
// User Login(Sign In) 또는 Sign Up(Sign Up)을 선택할 수 있도록 안내합니다.
//
// 사용법:
// - 어디서든 `SignInAndUpScreen()`을 라우트에 추가하여 사용 가능
// - 배경 이미지, 기본 색상은 theme과 함께 유연하게 대응 가능
// - 라우팅은 '/auth/sign-in' 및 '/auth/sign-up'으로 연결
// =============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/themes/app_shadows.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_toast.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../functions/sign_in_with_google.dart';
import '../../functions/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInAndUpScreen extends StatefulWidget {
  const SignInAndUpScreen({super.key});

  @override
  State<SignInAndUpScreen> createState() => _SignInAndUpScreenState();
}

class _SignInAndUpScreenState extends State<SignInAndUpScreen> {
  bool _isLoading = false;
  bool _isNavigatingToHome = false;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('[SIGN-IN-UP SCREEN] Starting Apple Sign-In process');
      final result = await AppleSignInHandler.signIn();

      if (!mounted) return;

      debugPrint(
        '[SIGN-IN-UP SCREEN] Apple Sign-In result - Success: ${result.isSuccess}, Failure: ${result.isFailure}',
      );
      debugPrint('[SIGN-IN-UP SCREEN] Is new user: ${result.isNewUser}');

      if (result.isFailure) {
        debugPrint('[SIGN-IN-UP SCREEN] Apple sign-in failed: ${result.error}');
        ModernToast.showError(context, result.error ?? 'Apple sign-in failed');
        return;
      }

      if (result.isNewUser) {
        debugPrint(
          '[SIGN-IN-UP SCREEN] NEW USER - Navigating to social sign-up screen',
        );
        debugPrint(
          '[SIGN-IN-UP SCREEN] Apple data being passed: ${result.socialData?.keys.toList()}',
        );
        // Navigate to social sign-up screen with Apple data
        context.go(
          '/auth/social-sign-up',
          extra: {'socialData': result.socialData, 'provider': 'apple'},
        );
      } else {
        debugPrint(
          '[SIGN-IN-UP SCREEN] EXISTING USER - Navigating to home screen',
        );
        debugPrint(
          '[SIGN-IN-UP SCREEN] User entity: ${result.userEntity?.fullName}',
        );
        // Existing user - set navigation state and go to home
        setState(() => _isNavigatingToHome = true);
        context.go('/home');
        return; // Don't execute finally block to maintain loading state
      }
    } catch (e) {
      debugPrint('[SIGN-IN-UP SCREEN] Exception during Apple Sign-In: $e');
      if (mounted) {
        ModernToast.showError(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('[SIGN-IN-UP SCREEN] Starting Google Sign-In process');
      final result = await SignInWithGoogle.signIn();

      debugPrint(
        '[SIGN-IN-UP SCREEN] Google Sign-In completed, checking mounted state',
      );
      if (!mounted) {
        debugPrint('[SIGN-IN-UP SCREEN] Widget not mounted, returning early');
        return;
      }

      debugPrint('[SIGN-IN-UP SCREEN] Widget still mounted, processing result');

      debugPrint(
        '[SIGN-IN-UP SCREEN] Google Sign-In result - Success: ${result.isSuccess}, Failure: ${result.isFailure}',
      );
      debugPrint('[SIGN-IN-UP SCREEN] Is new user: ${result.isNewUser}');
      debugPrint('[SIGN-IN-UP SCREEN] Result type: ${result.runtimeType}');
      debugPrint('[SIGN-IN-UP SCREEN] Provider: ${result.provider}');

      if (result.isFailure) {
        debugPrint('[SIGN-IN-UP SCREEN] Sign-in failed: ${result.error}');
        ModernToast.showError(context, result.error ?? 'Google sign-in failed');
        return;
      }

      if (result.isNewUser) {
        debugPrint(
          '[SIGN-IN-UP SCREEN] NEW USER - Navigating to social sign-up screen',
        );
        debugPrint(
          '[SIGN-IN-UP SCREEN] Social data being passed: ${result.socialData?.keys.toList()}',
        );
        // Navigate to social sign-up screen with social data
        context.go(
          '/auth/social-sign-up',
          extra: {
            'socialData': result.socialData,
            'provider': result.provider?.name,
          },
        );
      } else {
        debugPrint(
          '[SIGN-IN-UP SCREEN] EXISTING USER - Navigating to home screen',
        );
        debugPrint(
          '[SIGN-IN-UP SCREEN] User entity: ${result.userEntity?.fullName}',
        );
        // Existing user - set navigation state and go to home
        setState(() => _isNavigatingToHome = true);
        context.go('/home');
        return; // Don't execute finally block to maintain loading state
      }
    } catch (e) {
      debugPrint('[SIGN-IN-UP SCREEN] Exception during Google Sign-In: $e');
      if (mounted) {
        ModernToast.showError(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      forceKeepLoading: _isNavigatingToHome,
      duration: const Duration(seconds: 5),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary,
                AppColors.secondary.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  AppCommonColors.white.withValues(alpha: 0.0),
                  AppCommonColors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        ),

                        // 로고/아이콘 Animation
                        Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppCommonColors.white.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppCommonColors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.rocket_launch_outlined,
                                size: 60,
                                color: AppCommonColors.white,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 1000.ms)
                            .scale(delay: 300.ms, duration: 800.ms)
                            .rotate(
                              delay: 1100.ms,
                              duration: 2000.ms,
                              begin: 0,
                              end: 0.05,
                            ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),

                        // 메인 타이틀
                        Text(
                              "Let's get started",
                              style: AppTypography.display.copyWith(
                                color: AppCommonColors.white,
                                fontWeight: AppFontWeights.extraBold,
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0, duration: 1000.ms),

                        const SizedBox(height: 16),

                        // 서브 텍스트
                        Text(
                              "Everything starts from here\nYour journey begins now",
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppCommonColors.white.withValues(
                                  alpha: 0.9,
                                ),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate(delay: 800.ms)
                            .fadeIn(duration: 1000.ms)
                            .slideY(begin: 0.2, end: 0, duration: 1000.ms),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        ),

                        // Button 영역
                        Column(
                          children: [
                            // Login Button (흰색 배경)
                            SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: AppShadows.primaryShadow(
                                        AppCommonColors.white,
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          context.push('/auth/sign-in'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppCommonColors.white,
                                        foregroundColor: AppColors.primary,
                                        elevation: 0,
                                        shadowColor: AppCommonColors.white
                                            .withValues(alpha: 0.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                      ),
                                      child: Text(
                                        'Log in',
                                        style: AppTypography.button.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate(delay: 1200.ms)
                                .fadeIn(duration: 800.ms)
                                .slideY(begin: 0.4, end: 0, duration: 800.ms),

                            const SizedBox(height: 16),

                            // Sign Up Button (아웃라인)
                            SizedBox(
                                  width: double.infinity,
                                  child: ModernButton(
                                    text: 'Create Account',
                                    onPressed: () =>
                                        context.push('/auth/sign-up'),
                                    type: ModernButtonType.outline,
                                    customColor: AppCommonColors.white,
                                    height: 56,
                                  ),
                                )
                                .animate(delay: 1400.ms)
                                .fadeIn(duration: 800.ms)
                                .slideY(begin: 0.4, end: 0, duration: 800.ms),

                            const SizedBox(height: 24),

                            // Divider with "OR"
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppCommonColors.white.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppCommonColors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: AppFontWeights.semiBold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppCommonColors.white.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate(delay: 1500.ms).fadeIn(duration: 600.ms),

                            const SizedBox(height: 24),

                            // Google Sign-In Button (hidden on web)
                            if (!kIsWeb) ...[
                              SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppCommonColors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        // boxShadow: AppShadows.primaryShadow(AppCommonColors.white),
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
                                  .animate(delay: 1600.ms)
                                  .fadeIn(duration: 800.ms)
                                  .slideY(begin: 0.4, end: 0, duration: 800.ms),
                            ],

                            // Apple Sign-In Button (hidden on web and Android)
                            if (!kIsWeb && !Platform.isAndroid) ...[
                              const SizedBox(height: 16),
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
                                  .animate(delay: 1700.ms)
                                  .fadeIn(duration: 800.ms)
                                  .slideY(begin: 0.4, end: 0, duration: 800.ms),
                            ],
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Bottom 텍스트 with clickable links
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              'By continuing, you agree to our ',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppCommonColors.white.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _launchURL('https://appbuildchat.com'),
                              child: Text(
                                'Terms',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppCommonColors.white.withValues(
                                    alpha: 0.7,
                                  ),
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppCommonColors.white
                                      .withValues(alpha: 0.7),
                                  fontWeight: AppFontWeights.semiBold,
                                ),
                              ),
                            ),
                            Text(
                              ' & ',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppCommonColors.white.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _launchURL('https://appbuildchat.com'),
                              child: Text(
                                'Privacy Policy',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppCommonColors.white.withValues(
                                    alpha: 0.7,
                                  ),
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppCommonColors.white
                                      .withValues(alpha: 0.7),
                                  fontWeight: AppFontWeights.semiBold,
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 1600.ms).fadeIn(duration: 800.ms),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
