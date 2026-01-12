// =============================================================================
// SIGN UP SCREEN
// =============================================================================
//
// This file allows users to enter name, email, password, and role
// to register through Firebase Auth and Firestore.
//
// Usage:
// 1. User enters name/email/password/role
// 2. Shows error if password confirmation doesn't match
// 3. After validation, calls `signUpWithEmail()` to create account
// 4. Navigates to login screen on success
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/validators.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_dropdown.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../app_config.dart';
import '../../../user/entities/role.dart';

class SignUpScreen extends StatefulWidget {
  final Map<String, dynamic>? googleData;

  const SignUpScreen({super.key, this.googleData});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ============================================================================
  // State and Controller Declarations
  // ============================================================================

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Role? _selectedRole;
  bool _isLoading = false;
  bool _isGoogleSignUp = false;
  String? _googlePhotoUrl;
  String? _googleUid;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Email checking variables
  bool _isCheckingEmail = false;
  bool? _isEmailAvailable;
  String? _checkedEmail;

  @override
  void initState() {
    super.initState();
    _initializeGoogleData();
  }

  void _initializeGoogleData() {
    if (widget.googleData != null) {
      _isGoogleSignUp = widget.googleData!['isGoogleSignUp'] ?? false;
      _googleUid = widget.googleData!['uid'];
      _googlePhotoUrl = widget.googleData!['photoUrl'];

      // Pre-fill form fields with Google data
      _emailController.text = widget.googleData!['email'] ?? '';
      _firstNameController.text = widget.googleData!['firstName'] ?? '';
      _lastNameController.text = widget.googleData!['lastName'] ?? '';

      // Set default role
      _selectedRole = Role.user;
    }
  }

  // ============================================================================
  // Sign Up Handler Function
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
        'password': _passwordController.text,
        'role': _selectedRole!,
        if (_isGoogleSignUp) 'isGoogleSignUp': true,
        if (_googleUid != null) 'googleUid': _googleUid,
        if (_googlePhotoUrl != null) 'profileImageUrl': _googlePhotoUrl,
      };

      if (!mounted) return;

      // Navigate to TNC screen instead of directly signing up
      context.go('/auth/sign-up-tnc', extra: signUpData);
    } catch (e) {
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

  // ============================================================================
  // Email Availability Check Function
  // ============================================================================

  Future<void> _checkEmailAvailability() async {
    final email = _emailController.text.trim();

    // Validate email format first
    final emailValidation = Validators.email(email);
    if (emailValidation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailValidation),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingEmail = true;
      _isEmailAvailable = null;
      _checkedEmail = null;
    });

    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('checkEmailAvailability');

      final result = await callable.call({'email': email});
      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        setState(() {
          _isEmailAvailable = data['available'] as bool;
          _checkedEmail = email;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] as String),
              backgroundColor: _isEmailAvailable!
                  ? AppCommonColors.green
                  : Theme.of(context).colorScheme.error,
            ),
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Failed to check email availability');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking email: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {
        _isEmailAvailable = null;
        _checkedEmail = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
        });
      }
    }
  }

  // ============================================================================
  // Visual Feedback Methods
  // ============================================================================

  Widget? _getEmailSuffixIcon() {
    if (_isEmailAvailable != null &&
        _checkedEmail == _emailController.text.trim()) {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: Icon(
          _isEmailAvailable! ? Icons.check_circle : Icons.cancel,
          color: _isEmailAvailable!
              ? AppCommonColors.green
              : AppCommonColors.red,
          size: AppDimensions.iconM,
        ),
      );
    }
    return null;
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    } else if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    } else if (value.trim().length > 20) {
      return 'Name must be less than 20 characters';
    }
    return null;
  }

  String? _validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your nickname';
    } else if (value.trim().length < 2) {
      return 'Nickname must be at least 2 characters';
    } else if (value.trim().length > 15) {
      return 'Nickname must be less than 15 characters';
    } else if (value.contains(' ')) {
      return 'Nickname cannot contain spaces';
    }
    return null;
  }

  // ============================================================================
  // UI Construction
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
        body: SafeArea(
          child: Container(
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
            child: SingleChildScrollView(
              padding: AppSpacing.paddingXXL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header animation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create account', style: AppTypography.headline1)
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideX(begin: -0.2, end: 0, duration: 800.ms),
                      AppSpacing.v8,
                      Text(
                            'Sign up to get started!',
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
                        // Name input (separated first and last name)
                        Row(
                          children: [
                            Expanded(
                              child:
                                  ModernTextField(
                                        controller: _firstNameController,
                                        labelText: 'First Name',
                                        hintText: 'First name',
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
                                        hintText: 'Last name',
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

                        // Email input with check button
                        _isGoogleSignUp
                            ? ModernTextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    labelText: 'Email',
                                    hintText: 'Enter your email address',
                                    enabled: false,
                                    validator: Validators.email,
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.secondary,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.check_circle,
                                      color: AppCommonColors.green,
                                      size: AppDimensions.iconM,
                                    ),
                                  )
                                  .animate(delay: 600.ms)
                                  .fadeIn(duration: 600.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 600.ms)
                            : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ModernTextField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          labelText: 'Email',
                                          hintText: 'Enter your email address',
                                          validator: (value) {
                                            // First check basic email validation
                                            final emailValidation =
                                                Validators.email(value);
                                            if (emailValidation != null) {
                                              return emailValidation;
                                            }

                                            // Skip email availability check in test mode
                                            if (AppConfig
                                                .skipEmailVerification) {
                                              return null;
                                            }

                                            // Check if email has been verified
                                            final email = value?.trim() ?? '';
                                            if (_checkedEmail != email) {
                                              return 'Please check email availability first';
                                            }

                                            // Check if email is available
                                            if (_isEmailAvailable != true) {
                                              return 'This email is not available';
                                            }

                                            return null;
                                          },
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            color: AppColors.secondary,
                                          ),
                                          suffixIcon: _getEmailSuffixIcon(),
                                          onChanged: (value) {
                                            // Reset email check state when text changes
                                            if (_checkedEmail != null &&
                                                _checkedEmail != value.trim()) {
                                              setState(() {
                                                _isEmailAvailable = null;
                                                _checkedEmail = null;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      // Hide Check button in test mode
                                      if (!AppConfig.skipEmailVerification) ...[
                                        AppSpacing.h12,
                                        SizedBox(
                                          height: AppDimensions.textFieldHeight,
                                          child: ElevatedButton(
                                            onPressed: _isCheckingEmail
                                                ? null
                                                : _checkEmailAvailability,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor:
                                                  AppCommonColors.white,
                                              padding:
                                                  AppSpacing.paddingHorizontalL,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    AppDimensions.borderRadiusM,
                                              ),
                                            ),
                                            child: _isCheckingEmail
                                                ? SizedBox(
                                                    width: AppDimensions.iconS,
                                                    height: AppDimensions.iconS,
                                                    child:
                                                        const CircularProgressIndicator(
                                                          color: AppCommonColors
                                                              .white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Text(
                                                    'Check',
                                                    style: TextStyle(
                                                      fontWeight: AppFontWeights
                                                          .semiBold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                  .animate(delay: 600.ms)
                                  .fadeIn(duration: 600.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v20,

                        // Password input - hidden for Google sign-ups
                        if (!_isGoogleSignUp)
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
                              .animate(delay: 650.ms)
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        if (!_isGoogleSignUp) AppSpacing.v20,

                        // Password confirmation - hidden for Google sign-ups
                        if (!_isGoogleSignUp)
                          ModernTextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                labelText: 'Confirm Password',
                                hintText: 'Confirm your password',
                                validator: (value) {
                                  if ((value ?? '').isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.secondary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.secondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              )
                              .animate(delay: 700.ms)
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v20,

                        // Role selection
                        ModernDropdown<Role>(
                              value: _selectedRole,
                              onChanged: (role) =>
                                  setState(() => _selectedRole = role),
                              labelText: 'Role',
                              hintText: 'Select your role',
                              validator: (value) =>
                                  value == null ? 'Please select a role' : null,
                              prefixIcon: Icon(
                                Icons.badge_outlined,
                                color: AppColors.secondary,
                              ),
                              items: Role.values
                                  .where(
                                    (role) => role != Role.admin,
                                  ) // Comment this line to enable admin registration
                                  .map(
                                    (role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role.name.toUpperCase(),
                                        style: AppTypography.bodyRegular
                                            .copyWith(fontSize: 10),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                            .animate(delay: 750.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms),

                        AppSpacing.v32,

                        // Sign up button
                        SizedBox(
                              width: double.infinity,
                              child: ModernButton(
                                text: 'Continue',
                                onPressed: _proceedToTerms,
                                isLoading: _isLoading,
                                type: ModernButtonType.primary,
                                height: AppDimensions.buttonHeight,
                              ),
                            )
                            .animate(delay: 850.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0, duration: 800.ms),
                      ],
                    ),
                  ),

                  AppSpacing.v40,

                  // Bottom login link
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a member? ",
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
                      .animate(delay: 950.ms)
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
  // Resource Disposal
  // ============================================================================

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
