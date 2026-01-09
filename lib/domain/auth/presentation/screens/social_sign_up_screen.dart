// =============================================================================
// SOCIAL SIGN UP SCREEN (Google/Apple)
// =============================================================================
//
// This screen is specifically for users who signed in with Google or Apple
// but don't have an existing user document in Firestore.
// It pre-fills information from the social provider and collects additional
// required fields like nickname and role.
//
// Usage:
// - Receives social data from Google/Apple sign-in
// - Pre-fills email, first name, last name, profile photo
// - Collects nickname, role from user
// - No password fields (not needed for social auth)
// - Navigates to T&C screen then completes registration
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/validators.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_dropdown.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../user/entities/role.dart';
import '../../models/social_sign_in_result.dart';

class SocialSignUpScreen extends StatefulWidget {
  final Map<String, dynamic>? socialData;
  final SocialProvider? provider;

  const SocialSignUpScreen({super.key, this.socialData, this.provider});

  @override
  State<SocialSignUpScreen> createState() => _SocialSignUpScreenState();
}

class _SocialSignUpScreenState extends State<SocialSignUpScreen> {
  // ============================================================================
  // State and Controller Declarations
  // ============================================================================

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  Role? _selectedRole;
  bool _isLoading = false;

  String? _profileImageUrl;
  String? _socialUid;

  @override
  void initState() {
    super.initState();
    _initializeSocialData();
  }

  void _initializeSocialData() {
    debugPrint('[SOCIAL SIGN-UP] Screen loaded - provider: ${widget.provider}');
    debugPrint(
      '[SOCIAL SIGN-UP] Provider type: ${widget.provider.runtimeType}',
    );
    debugPrint(
      '[SOCIAL SIGN-UP] Is Google: ${widget.provider == SocialProvider.google}',
    );
    debugPrint(
      '[SOCIAL SIGN-UP] Is Apple: ${widget.provider == SocialProvider.apple}',
    );
    debugPrint(
      '[SOCIAL SIGN-UP] Current Firebase user on load: ${FirebaseAuth.instance.currentUser?.uid}',
    );

    if (widget.socialData != null) {
      debugPrint(
        '[SOCIAL SIGN-UP] Initializing with data: ${widget.socialData!.keys.toList()}',
      );
      debugPrint(
        '[SOCIAL SIGN-UP] Social data contents: ${widget.socialData!}',
      );

      _socialUid = widget.socialData!['uid'];
      _profileImageUrl = widget.socialData!['photoUrl'];

      debugPrint('[SOCIAL SIGN-UP] Extracted social UID: $_socialUid');
      debugPrint(
        '[SOCIAL SIGN-UP] Extracted profile image URL: $_profileImageUrl',
      );

      // Pre-fill form fields with social data
      _emailController.text = widget.socialData!['email'] ?? '';
      _firstNameController.text = widget.socialData!['firstName'] ?? '';
      _lastNameController.text = widget.socialData!['lastName'] ?? '';

      // Set default role
      _selectedRole = Role.user;
    }
  }

  // ============================================================================
  // Helper Functions
  // ============================================================================

  String _getRoleDisplayName(Role role) {
    switch (role) {
      case Role.admin:
        return 'Admin';
      case Role.user:
        return 'User';
    }
  }

  // ============================================================================
  // Validation Functions
  // ============================================================================

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 2) {
      return 'Must be at least 2 characters';
    }
    return null;
  }

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your nickname';
    }
    if (value.trim().length < 2) {
      return 'Nickname must be at least 2 characters';
    }
    if (value.trim().length > 15) {
      return 'Nickname must be less than 15 characters';
    }
    if (value.contains(' ')) {
      return 'Nickname cannot contain spaces';
    }
    return null;
  }

  // ============================================================================
  // Continue to Terms Handler Function
  // ============================================================================

  Future<void> _proceedToTerms() async {
    // Early return if form validation fails
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare signup data to pass through screens
      final signUpData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'nickname': _nicknameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole!,
        'isSocialSignUp': true,
        'socialProvider': widget.provider?.name,
        'socialUid': _socialUid,
        if (_profileImageUrl != null) 'profileImageUrl': _profileImageUrl,
      };

      if (!mounted) return;

      debugPrint(
        '[SOCIAL SIGN-UP] Proceeding to T&C with data: ${signUpData.keys.toList()}',
      );
      debugPrint(
        '[SOCIAL SIGN-UP] Social UID being passed: ${signUpData['socialUid']}',
      );
      debugPrint('[SOCIAL SIGN-UP] Email being passed: ${signUpData['email']}');
      debugPrint('[SOCIAL SIGN-UP] Full data being passed: $signUpData');
      debugPrint(
        '[SOCIAL SIGN-UP] Current Firebase user: ${FirebaseAuth.instance.currentUser?.uid}',
      );
      // Navigate to TNC screen
      context.go('/auth/sign-up-tnc', extra: signUpData);
    } catch (e) {
      debugPrint('[SOCIAL SIGN-UP] Error proceeding to terms: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String providerName = 'SOCIAL';
    if (widget.provider == SocialProvider.google) {
      providerName = 'GOOGLE';
    } else if (widget.provider == SocialProvider.apple) {
      providerName = 'APPLE';
    }

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
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.v40,

                  // Header animation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                            'Complete your profile',
                            style: AppTypography.headline1,
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideX(begin: -0.2, end: 0, duration: 800.ms),
                      AppSpacing.v8,
                      Text(
                            'We\'ve pre-filled some information from $providerName',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.secondary.withValues(alpha: 0.7),
                            ),
                          )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 800.ms)
                          .slideX(begin: -0.2, end: 0, duration: 800.ms),
                    ],
                  ),

                  AppSpacing.v24,

                  // Profile photo preview (if available)
                  if (_profileImageUrl != null)
                    Center(
                          child: Container(
                            width: AppDimensions.containerS,
                            height: AppDimensions.containerS,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXXL,
                              ),
                              child: Image.network(
                                _profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: AppDimensions.radiusXXL,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 800.ms)
                        .scale(delay: 100.ms, duration: 600.ms),

                  if (_profileImageUrl != null) const SizedBox(height: 24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name input (separated first and last name)
                        Row(
                          children: [
                            Expanded(
                              child:
                                  ModernTextField(
                                        controller: _firstNameController,
                                        labelText: 'First Name',
                                        hintText: 'Enter your first name',
                                        validator: _validateName,
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: AppColors.secondary,
                                        ),
                                      )
                                      .animate(delay: 400.ms)
                                      .fadeIn(duration: 600.ms)
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 600.ms,
                                      ),
                            ),
                            AppSpacing.h16,
                            Expanded(
                              child:
                                  ModernTextField(
                                        controller: _lastNameController,
                                        labelText: 'Last Name',
                                        hintText: 'Enter your last name',
                                        validator: _validateName,
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: AppColors.secondary,
                                        ),
                                      )
                                      .animate(delay: 450.ms)
                                      .fadeIn(duration: 600.ms)
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 600.ms,
                                      ),
                            ),
                          ],
                        ),

                        AppSpacing.v20,

                        // Nickname input
                        ModernTextField(
                              controller: _nicknameController,
                              labelText: 'Nickname',
                              hintText: 'Enter your nickname',
                              validator: _validateNickname,
                              maxLength: 15,
                              prefixIcon: Icon(
                                Icons.alternate_email,
                                color: AppColors.secondary,
                              ),
                            )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v20,

                        // Email input (disabled, from social provider)
                        ModernTextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              labelText: 'Email',
                              hintText: 'Your email address',
                              enabled: false,
                              validator: Validators.email,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.secondary,
                              ),
                              suffixIcon: widget.provider != null
                                  ? Icon(
                                      widget.provider == SocialProvider.google
                                          ? Icons.g_mobiledata_rounded
                                          : widget.provider ==
                                                SocialProvider.apple
                                          ? Icons.apple
                                          : Icons.person,
                                      color:
                                          widget.provider ==
                                              SocialProvider.google
                                          ? AppColors.primary
                                          : widget.provider ==
                                                SocialProvider.apple
                                          ? AppCommonColors.black
                                          : AppCommonColors.grey,
                                      size: AppDimensions.iconL,
                                    )
                                  : null,
                            )
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v20,

                        // Role selection
                        ModernDropdown<Role>(
                              value: _selectedRole,
                              onChanged: (role) =>
                                  setState(() => _selectedRole = role),
                              items: Role.values
                                  .where(
                                    (role) => role != Role.admin,
                                  ) // Comment this line to enable admin registration
                                  .map((role) {
                                    return DropdownMenuItem<Role>(
                                      value: role,
                                      child: Text(
                                        _getRoleDisplayName(role),
                                        style: AppTypography.bodyRegular,
                                      ),
                                    );
                                  })
                                  .toList(),
                              labelText: 'Role',
                              hintText: 'Select your role',
                              validator: (value) =>
                                  value == null ? 'Please select a role' : null,
                              prefixIcon: Icon(
                                Icons.work_outline,
                                color: AppColors.secondary,
                              ),
                            )
                            .animate(delay: 650.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v40,

                        // Continue button
                        SizedBox(
                              width: double.infinity,
                              child: ModernButton(
                                text: 'Continue',
                                onPressed: _proceedToTerms,
                                type: ModernButtonType.primary,
                                height: AppDimensions.textFieldHeight,
                                isLoading: _isLoading,
                              ),
                            )
                            .animate(delay: 700.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms),

                        AppSpacing.v24,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
