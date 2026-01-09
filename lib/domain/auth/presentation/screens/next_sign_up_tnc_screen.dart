import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/modern_button.dart';

class NextSignUpTncScreen extends StatefulWidget {
  final Map<String, dynamic> signUpData;

  const NextSignUpTncScreen({super.key, required this.signUpData});

  @override
  State<NextSignUpTncScreen> createState() => _NextSignUpTncScreenState();
}

class _NextSignUpTncScreenState extends State<NextSignUpTncScreen> {
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _agreeToAll = false;

  void _updateAgreements() {
    setState(() {
      _agreeToAll = _agreeToTerms && _agreeToPrivacy;
    });
  }

  void _setAllAgreements(bool? value) {
    if (value == null) return;
    setState(() {
      _agreeToAll = value;
      _agreeToTerms = value;
      _agreeToPrivacy = value;
    });
  }

  void _proceed() {
    if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to required terms and privacy policy'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    // Navigate to complete screen with all data
    final completeData = {
      ...widget.signUpData,
      'agreeToTerms': _agreeToTerms,
      'agreeToPrivacy': _agreeToPrivacy,
    };

    context.go('/auth/sign-up-complete', extra: completeData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terms & Conditions', style: AppTypography.headline1)
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .slideX(begin: -0.2, end: 0, duration: 800.ms),
                    const SizedBox(height: 8),
                    Text(
                          'Please review and agree to our terms',
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.secondary.withValues(alpha: 0.7),
                          ),
                        )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 800.ms)
                        .slideX(begin: -0.2, end: 0, duration: 800.ms),
                  ],
                ),

                const SizedBox(height: 48),

                // Agreement options
                Column(
                  children: [
                    // All agreements
                    Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppCommonColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _agreeToAll
                                  ? AppColors.primary
                                  : AppCommonColors.grey400.withValues(
                                      alpha: 0.3,
                                    ),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _agreeToAll,
                                onChanged: _setAllAgreements,
                                activeColor: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Agree to all terms and conditions',
                                  style: AppTypography.bodyRegular.copyWith(
                                    fontWeight: AppFontWeights.semiBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms),

                    const SizedBox(height: 16),

                    // Individual agreements
                    _buildAgreementItem(
                      'Terms of Service (Required)',
                      'I agree to the terms of service',
                      _agreeToTerms,
                      (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                          _updateAgreements();
                        });
                      },
                      isRequired: true,
                      delay: 500,
                    ),

                    const SizedBox(height: 12),

                    _buildAgreementItem(
                      'Privacy Policy (Required)',
                      'I agree to the privacy policy',
                      _agreeToPrivacy,
                      (value) {
                        setState(() {
                          _agreeToPrivacy = value ?? false;
                          _updateAgreements();
                        });
                      },
                      isRequired: true,
                      delay: 600,
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Continue button
                SizedBox(
                      width: double.infinity,
                      child: ModernButton(
                        text: 'Create Account',
                        onPressed: _proceed,
                        type: ModernButtonType.primary,
                        height: 56,
                      ),
                    )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0, duration: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildAgreementItem(
    String title,
    String description,
    bool value,
    ValueChanged<bool?> onChanged, {
    required bool isRequired,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child:
          Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppCommonColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppCommonColors.grey400.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        onChanged(!value);
                      },
                      child: Checkbox(
                        value: value,
                        onChanged: onChanged,
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final url = title.contains('Terms')
                                  ? 'https://appbuildchat.com' // Terms of Service URL
                                  : 'https://appbuildchat.com'; // Privacy Policy URL
                              _launchURL(url);
                            },
                            child: Text(
                              title,
                              style: AppTypography.bodyRegular.copyWith(
                                fontWeight: AppFontWeights.semiBold,
                                color: AppColors.text,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              onChanged(!value);
                            },
                            child: Text(
                              description,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final url = title.contains('Terms')
                            ? 'https://appbuildchat.com' // Terms of Service URL
                            : 'https://appbuildchat.com'; // Privacy Policy URL
                        _launchURL(url);
                      },
                      child: Icon(
                        Icons.open_in_new,
                        color: AppColors.secondary.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: delay.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms),
    );
  }
}
