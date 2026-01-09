// =============================================================================
// FORGOT PASSWORD SCREEN (Password 재설정 Screen)
// =============================================================================
//
// 이 Screen은 User Email을 Input해 Password 재설정 Email을 받을 수 있도록 합니다.
//
// 사용법:
// 1. 유저가 Email Input 후 "Reset Password" Button 클릭
// 2. Email 형식이 올바르지 않으면 에러 표시
// 3. 유효한 Email일 경우 Firebase에 Password 재설정 요청 전송
// 4. 성공 시 안내 메시지 후 Login Screen으로 이동
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/validators.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../functions/send_password_reset_email.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ============================================================================
  // State 및 Controller Declaration
  // ============================================================================

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // ============================================================================
  // Resource Disposal
  // ============================================================================

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Form validation check - abort if failed
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Send password reset email via Firebase
      final email = _emailController.text.trim();
      await sendPasswordResetEmail(email);

      if (!mounted) return;

      // Success - show success message and navigate to login screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email'),
          backgroundColor: AppCommonColors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Wait a moment before navigation to let user see the success message
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        context.go('/auth/sign-in');
      }
    } catch (e) {
      if (!mounted) return;

      // Show error message with better formatting
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: AppCommonColors.white,
            onPressed: () => _submit(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================================
  // UI Composition
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
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.text,
          title: null,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppCommonColors.white,
                AppColors.background.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.v60,

                  // 아이콘 Animation
                  Center(
                        child: Container(
                          width: AppDimensions.iconXXL * 3,
                          height: AppDimensions.iconXXL * 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_reset_outlined,
                            size: AppDimensions.iconXXL * 1.5,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(delay: 200.ms, duration: 600.ms),

                  AppSpacing.v40,

                  // Header Animation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reset password', style: AppTypography.headline1)
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 800.ms)
                          .slideX(begin: -0.2, end: 0, duration: 800.ms),
                      AppSpacing.v12,
                      Text(
                            'Enter your email address and we\'ll send you instructions to reset your password.',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.secondary.withValues(alpha: 0.8),
                              height: 1.6,
                            ),
                          )
                          .animate(delay: 600.ms)
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
                        // Email Input 필드
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
                            .animate(delay: 800.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v32,

                        // Password 재설정 Button
                        SizedBox(
                              width: double.infinity,
                              child: ModernButton(
                                text: 'Send Reset Link',
                                onPressed: _submit,
                                isLoading: _isLoading,
                                type: ModernButtonType.primary,
                                height: AppDimensions.buttonHeight,
                              ),
                            )
                            .animate(delay: 1000.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0, duration: 800.ms),
                      ],
                    ),
                  ),

                  AppSpacing.v48,

                  // Bottom Login Link
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remembered your password? ",
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.secondary.withValues(alpha: 0.8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/auth/sign-in'),
                            child: Text(
                              'Log in',
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

                  AppSpacing.v40,

                  // 추가 도움말 텍스트
                  Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            width: AppDimensions.dividerThickness,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary.withValues(alpha: 0.8),
                              size: AppDimensions.iconS,
                            ),
                            AppSpacing.h12,
                            Expanded(
                              child: Text(
                                'Check your email for a reset link. It may take a few minutes to arrive.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.8,
                                  ),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(delay: 1400.ms)
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.1, end: 0, duration: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
