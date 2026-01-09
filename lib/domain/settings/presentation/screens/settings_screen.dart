// =============================================================================
// SETTINGS SCREEN
// This screen controls the user's app settings.
// Includes options for user account (name, password, bio, etc.) and dangerous actions like logout and account deletion.
// Main features:
// 1. Load user name and email from Firebase
// 2. Navigate to setting pages on item selection (`/change-xxx`)
// 3. Provide logout and account deletion
// 4. Fetch blocked account info (for future UI use)
// Usage:
// - Use `context.push()` and `context.go()` for routing
// - Provide mock data when not logged in
// UI Structure:
// - AppBar + back button
// - Account settings section
// - Danger Zone section
// - Show loading indicator
// =============================================================================

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/widgets/modern_toast.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/skeletons/settings_skeleton.dart';
import '../../../../core/image_picker/upload_image.dart';
import '../../../auth/functions/delete_user_account.dart';
import '../../../auth/functions/reauthenticate_user.dart';
import '../../../auth/functions/reauthenticate_with_google.dart';
import '../../../auth/functions/reauthenticate_with_apple.dart';
import '../../functions/sign_out_with_email.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  String _firstName = 'User';
  String _lastName = '';
  String _userEmail = '';
  String? _profileImageUrl;
  bool _isLoading = true;
  List<String> _blockedAccounts = [];
  String? _authProvider;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      // Mock data for UI preview when not logged in
      setState(() {
        _firstName = 'User';
        _lastName = '';
        _userEmail = 'mock@email.com';
        _isLoading = false;
        _blockedAccounts = [];
      });
    } else {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBarWithBack(
        title: 'Settings',
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile');
          }
        },
      ),
      body: _currentUser == null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildProfileHeader(),
                      ),
                      AppSpacing.v32,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _accountSettingSection(),
                      ),
                      AppSpacing.v32,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _privacySettingsSection(),
                      ),
                      AppSpacing.v32,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _aboutSection(),
                      ),
                      AppSpacing.v40,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _dangerButtonSection(),
                      ),
                      AppSpacing.v32,
                    ],
                  ),
                ),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_rounded,
                          color: AppColors.accent,
                          size: AppDimensions.iconXXL * 1.6,
                        ),
                        AppSpacing.v16,
                        Text(
                          'Something went wrong',
                          style: AppTypography.headline2.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        AppSpacing.v8,
                        Text(
                          'Failed to load user data',
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    _isLoading) {
                  return const SettingsSkeleton();
                }

                // Update user data from stream
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _firstName = userData['firstName'] ?? 'User';
                        _lastName = userData['lastName'] ?? '';
                        _userEmail =
                            userData['email'] ??
                            _currentUser!.email ??
                            'No email';
                        _profileImageUrl = userData['imageUrl'];
                        _blockedAccounts = List<String>.from(
                          userData['blockedUsers'] ?? [],
                        );
                        _isLoading = false;
                      });
                    }
                  });
                }

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildProfileHeader(),
                          ),
                          AppSpacing.v32,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _accountSettingSection(),
                          ),
                          AppSpacing.v32,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _privacySettingsSection(),
                          ),
                          AppSpacing.v32,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _aboutSection(),
                          ),
                          AppSpacing.v40,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _dangerButtonSection(),
                          ),
                          AppSpacing.v32,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: AppShadows.primaryShadow(AppColors.primary),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child:
                      _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? Image.network(
                          _profileImageUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: AppCommonColors.white,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 36,
                            color: AppCommonColors.white,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showProfileImageOptions,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppCommonColors.white,
                        width: 2,
                      ),
                      boxShadow: AppShadows.primaryShadow(AppColors.primary),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppCommonColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_firstName $_lastName'.trim(),
                  style: AppTypography.headline2.copyWith(
                    color: AppColors.text,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _accountSettingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: AppTypography.headline3.copyWith(
            color: AppColors.text,
            fontWeight: AppFontWeights.bold,
          ),
        ),
        AppSpacing.v16,
        _buildSettingTile(
          icon: Icons.person_rounded,
          title: 'Change Name',
          subtitle: 'Update your first and last name',
          onTap: () => context.push('/settings/change-username'),
        ),
        _buildSettingTile(
          icon: Icons.badge_rounded,
          title: 'Change Nickname',
          subtitle: 'Update your display nickname',
          onTap: () => context.push('/settings/change-nickname'),
        ),
        _buildSettingTile(
          icon: Icons.phone_rounded,
          title: 'Change Phone Number',
          subtitle: 'Update your contact number',
          onTap: () => context.push('/settings/change-phone'),
        ),
        _buildSettingTile(
          icon: Icons.description_rounded,
          title: 'Change Bio',
          subtitle: 'Tell others about yourself',
          onTap: () => context.push('/settings/change-bio'),
        ),
        // Only show Change Password for email auth users
        if (_authProvider == 'email')
          _buildSettingTile(
            icon: Icons.lock_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => context.push('/settings/change-password'),
          ),
        // _buildNotificationToggle(), // Commented out as requested
        _buildSettingTile(
          icon: Icons.feedback_rounded,
          title: 'Send Feedback',
          subtitle: 'Help us improve the app',
          onTap: () => context.push('/settings/feedback'),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Color? iconColor,
  }) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppCommonColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: AppShadows.primaryShadow(AppColors.primary),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.text,
                              fontWeight: AppFontWeights.semiBold,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.secondary.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _privacySettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy & Security',
          style: AppTypography.headline3.copyWith(
            color: AppColors.text,
            fontWeight: AppFontWeights.bold,
          ),
        ),
        AppSpacing.v16,
        _buildSettingTile(
          icon: Icons.block_rounded,
          title: 'Blocked Accounts',
          subtitle: '${_blockedAccounts.length} accounts blocked',
          onTap: () {
            ModernToast.showInfo(
              context,
              'Blocked accounts management coming soon!',
            );
          },
        ),
      ],
    );
  }

  Widget _aboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: AppTypography.headline3.copyWith(
            color: AppColors.text,
            fontWeight: AppFontWeights.bold,
          ),
        ),
        AppSpacing.v16,
        _buildSettingTile(
          icon: Icons.privacy_tip_rounded,
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          onTap: () async {
            final uri = Uri.parse('https://appbuildchat.com');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              if (mounted) {
                ModernToast.showError(context, 'Could not open privacy policy');
              }
            }
          },
        ),
        _buildSettingTile(
          icon: Icons.description_rounded,
          title: 'Terms of Use',
          subtitle: 'Read our terms and conditions',
          onTap: () async {
            final uri = Uri.parse('https://appbuildchat.com');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              if (mounted) {
                ModernToast.showError(context, 'Could not open terms of use');
              }
            }
          },
        ),
      ],
    );
  }

  Widget _dangerButtonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: AppTypography.headline3.copyWith(
            color: AppColors.accent,
            fontWeight: AppFontWeights.bold,
          ),
        ),
        AppSpacing.v16,
        _buildSettingTile(
          icon: Icons.logout_rounded,
          title: 'Log Out',
          subtitle: 'Sign out of your account',
          iconColor: AppColors.accent,
          onTap: _confirmLogOut,
        ),
        _buildSettingTile(
          icon: Icons.delete_forever_rounded,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          iconColor: AppColors.accent,
          onTap: _confirmDeleteAccount,
        ),
      ],
    );
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      setState(() {
        _blockedAccounts = [];
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        // Migrate authProvider if needed
        await _migrateAuthProviderIfNeeded(userData);

        setState(() {
          _firstName = userData['firstName'] ?? 'User';
          _lastName = userData['lastName'] ?? '';
          _userEmail = userData['email'] ?? _currentUser!.email ?? 'No email';
          _blockedAccounts = List<String>.from(userData['blockedUsers'] ?? []);
          _authProvider = userData['authProvider'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'Failed to load user data: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _migrateAuthProviderIfNeeded(
    Map<String, dynamic> userData,
  ) async {
    // Check if authProvider field is missing
    if (userData['authProvider'] != null) {
      debugPrint(
        '[SETTINGS] Auth provider already exists: ${userData['authProvider']}',
      );
      return; // Already has authProvider, no migration needed
    }

    debugPrint('[SETTINGS] Auth provider missing, attempting migration...');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Detect provider from Firebase providerData
      String detectedProvider = 'unknown';
      for (final providerProfile in user.providerData) {
        final providerId = providerProfile.providerId;
        if (providerId == 'password') {
          detectedProvider = 'email';
          break;
        } else if (providerId == 'google.com') {
          detectedProvider = 'google';
          break;
        } else if (providerId == 'apple.com') {
          detectedProvider = 'apple';
          break;
        }
      }

      if (detectedProvider != 'unknown') {
        debugPrint(
          '[SETTINGS] Detected auth provider: $detectedProvider, updating user document',
        );

        // Update the user document with the detected auth provider
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'authProvider': detectedProvider,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Update local state
        _authProvider = detectedProvider;

        debugPrint('[SETTINGS] Auth provider migration completed');
      } else {
        debugPrint(
          '[SETTINGS] Could not detect auth provider from providerData',
        );
      }
    } catch (e) {
      debugPrint('[SETTINGS] Auth provider migration failed: $e');
      // Don't throw error, this is non-critical
    }
  }

  Future<void> _confirmLogOut() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppCommonColors.grey100,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: AppCommonColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logOut();
    }
  }

  Future<void> _logOut() async {
    final result = await signOut();
    if (result.isSuccess) {
      if (mounted) {
        ModernToast.showSuccess(context, 'Logged out successfully');
        context.go('/auth/sign-in-and-up');
      }
    } else {
      if (mounted) {
        ModernToast.showError(context, result.message ?? 'Failed to log out');
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final theme = Theme.of(context);

    // First confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? All your data will be permanently deleted and cannot be recovered.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppCommonColors.grey100,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: AppCommonColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Provider-specific authentication
    await _showProviderReAuthenticationDialog();
  }

  Future<void> _showProviderReAuthenticationDialog() async {
    final provider = _authProvider ?? 'unknown';
    debugPrint(
      '[SETTINGS] Starting provider-specific re-authentication for: $provider',
    );

    try {
      if (provider == 'email') {
        // Show password input dialog for email users
        await _showPasswordConfirmationDialog();
      } else if (provider == 'google') {
        // Show Google re-authentication dialog
        await _showGoogleReAuthDialog();
      } else if (provider == 'apple') {
        // Show Apple re-authentication dialog
        await _showAppleReAuthDialog();
      } else {
        // Unknown provider - try to detect from Firebase
        await _showUnknownProviderDialog();
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _showGoogleReAuthDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Re-authenticate with Google'),
        content: const Text(
          'To delete your account, please re-authenticate with your Google account.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppCommonColors.grey100,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: AppCommonColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      // Show loading toast for re-authentication
      if (mounted) {
        ModernToast.showInfo(context, 'Re-authenticating with Google...');
      }

      await reauthenticateWithGoogle();

      // Show loading toast for account deletion
      if (mounted) {
        ModernToast.showInfo(context, 'Deleting account...');
      }

      await deleteUserAccount();

      if (mounted) {
        ModernToast.showSuccess(context, 'Account deleted successfully');
        context.go('/auth/sign-in-and-up');
      }
    } catch (e) {
      debugPrint('[SETTINGS] Google re-auth failed: $e');

      if (mounted) {
        String errorMessage;
        if (e.toString().contains('cancelled')) {
          errorMessage =
              'Google authentication was cancelled. Please try again.';
        } else if (e.toString().contains('mismatch')) {
          errorMessage =
              'Please sign in with the same Google account used for registration.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        } else {
          errorMessage =
              'Failed to authenticate with Google. Please try again.';
        }

        ModernToast.showError(context, errorMessage);

        // Show retry dialog
        _showRetryDialog('Google Re-authentication Failed', errorMessage, () {
          _showGoogleReAuthDialog();
        });
      }
    } finally {
      if (mounted) {}
    }
  }

  Future<void> _showAppleReAuthDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Re-authenticate with Apple'),
        content: const Text(
          'To delete your account, please re-authenticate with your Apple account.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppCommonColors.grey100,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: AppCommonColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      // Show loading toast for re-authentication
      if (mounted) {
        ModernToast.showInfo(context, 'Re-authenticating with Apple...');
      }

      await reauthenticateWithApple();

      // Show loading toast for account deletion
      if (mounted) {
        ModernToast.showInfo(context, 'Deleting account...');
      }

      await deleteUserAccount();

      if (mounted) {
        ModernToast.showSuccess(context, 'Account deleted successfully');
        context.go('/auth/sign-in-and-up');
      }
    } catch (e) {
      debugPrint('[SETTINGS] Apple re-auth failed: $e');

      if (mounted) {
        String errorMessage;
        if (e.toString().contains('cancelled')) {
          errorMessage =
              'Apple authentication was cancelled. Please try again.';
        } else if (e.toString().contains('mismatch')) {
          errorMessage =
              'Please sign in with the same Apple account used for registration.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage =
              'Network error. Please check your connection and try again.';
        } else {
          errorMessage = 'Failed to authenticate with Apple. Please try again.';
        }

        ModernToast.showError(context, errorMessage);

        // Show retry dialog
        _showRetryDialog('Apple Re-authentication Failed', errorMessage, () {
          _showAppleReAuthDialog();
        });
      }
    } finally {
      if (mounted) {}
    }
  }

  Future<void> _showUnknownProviderDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account Authentication Required'),
        content: const Text(
          'To delete your account, we need to verify your identity. This will require re-authentication with your original sign-in method.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppCommonColors.grey100,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: AppCommonColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    // For unknown providers, try to detect from Firebase providerData
    await _detectAndReauthenticate();
  }

  Future<void> _detectAndReauthenticate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Try to detect the provider from Firebase
      String detectedProvider = 'unknown';
      for (final providerProfile in user.providerData) {
        final providerId = providerProfile.providerId;
        if (providerId == 'password') {
          detectedProvider = 'email';
          break;
        } else if (providerId == 'google.com') {
          detectedProvider = 'google';
          break;
        } else if (providerId == 'apple.com') {
          detectedProvider = 'apple';
          break;
        }
      }

      debugPrint('[SETTINGS] Detected auth provider: $detectedProvider');

      // Update the stored provider
      setState(() {
        _authProvider = detectedProvider;
      });

      // Retry with detected provider
      if (detectedProvider == 'email') {
        await _showPasswordConfirmationDialog();
      } else if (detectedProvider == 'google') {
        await _showGoogleReAuthDialog();
      } else if (detectedProvider == 'apple') {
        await _showAppleReAuthDialog();
      } else {
        throw Exception('Unable to determine authentication provider');
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(
          context,
          'Unable to determine authentication method. Please contact support.',
        );
      }
    }
  }

  Future<void> _showPasswordConfirmationDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PasswordConfirmationDialog(
        onConfirm: (password) async {
          await _deleteAccountWithPassword(password);
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteAccountWithPassword(String password) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      // Show loading toast for re-authentication
      if (mounted) {
        ModernToast.showInfo(context, 'Re-authenticating...');
      }

      // Re-authenticate user
      await reauthenticateCurrentUser(password);

      // Show loading toast for account deletion
      if (mounted) {
        ModernToast.showInfo(context, 'Deleting account...');
      }

      // Use the delete user account function
      await deleteUserAccount();

      if (mounted) {
        ModernToast.showSuccess(context, 'Account deleted successfully');
        context.go('/auth/sign-in-and-up');
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many attempts. Please wait a moment and try again.';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else {
        errorMessage = 'Failed to delete account. Please try again.';
      }

      throw Exception(errorMessage);
    } finally {
      if (mounted) {}
    }
  }

  // Show profile image options (upload, delete, etc.)
  void _showProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppCommonColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile Picture',
              style: AppTypography.headline3.copyWith(
                color: AppColors.text,
                fontWeight: AppFontWeights.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildImageOptionTile(
              icon: Icons.camera_alt_rounded,
              title: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            _buildImageOptionTile(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
              _buildImageOptionTile(
                icon: Icons.delete_rounded,
                title: 'Remove Photo',
                iconColor: AppColors.accent,
                textColor: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfileImage();
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppTypography.bodyRegular.copyWith(
                  color: textColor ?? AppColors.text,
                  fontWeight: AppFontWeights.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          // Web: Use XFile directly
          await _uploadProfileImageFromXFile(image);
        } else {
          // Mobile: Convert to File
          final File imageFile = File(image.path);
          await _uploadProfileImage(imageFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  // Upload profile image to Firebase Storage (XFile version for web)
  Future<void> _uploadProfileImageFromXFile(XFile imageFile) async {
    if (_currentUser == null) return;

    try {
      ModernToast.showInfo(context, 'Uploading image...');

      // Delete old image if exists
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
        await _deleteOldProfileImage();
      }

      final uploadResult = await uploadProfileImageFromXFile(
        _currentUser!.uid,
        imageFile,
        oldImageUrl: _profileImageUrl,
      );

      if (uploadResult.isSuccess) {
        final imageUrl = uploadResult.data!;

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({'imageUrl': imageUrl});

        // Update local state
        setState(() {
          _profileImageUrl = imageUrl;
        });

        if (mounted) {
          ModernToast.showSuccess(context, 'Profile image updated!');
        }
      } else {
        if (mounted) {
          ModernToast.showError(
            context,
            uploadResult.message ?? 'Upload failed',
          );
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ModernToast.showError(context, 'Failed to upload image');
      }
    }
  }

  // Upload profile image to Firebase Storage (File version for mobile)
  Future<void> _uploadProfileImage(File imageFile) async {
    if (_currentUser == null) return;

    try {
      ModernToast.showInfo(context, 'Uploading image...');

      // Delete old image if exists
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
        await _deleteOldProfileImage();
      }

      // Upload new image
      final storage = FirebaseStorage.instance;
      final String fileName =
          'profile_${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = storage.ref().child(
        'users/${_currentUser!.uid}/profile/$fileName',
      );

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with new image URL
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'imageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ModernToast.showSuccess(context, 'Profile picture updated!');
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'Failed to upload image: $e');
      }
    }
  }

  // Delete profile image
  Future<void> _deleteProfileImage() async {
    if (_currentUser == null) return;

    try {
      // Delete from Storage
      await _deleteOldProfileImage();

      // Remove from Firestore
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'imageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ModernToast.showSuccess(context, 'Profile picture removed');
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'Failed to remove profile picture: $e');
      }
    }
  }

  // Delete old profile image from Storage
  Future<void> _deleteOldProfileImage() async {
    if (_profileImageUrl == null || _profileImageUrl!.isEmpty) return;

    try {
      final storage = FirebaseStorage.instance;
      final Reference ref = storage.refFromURL(_profileImageUrl!);
      await ref.delete();
    } catch (e) {
      // Ignore storage deletion errors (file might not exist)
    }
  }

  // Show retry dialog for failed operations
  void _showRetryDialog(String title, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onRetry();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _PasswordConfirmationDialog extends StatefulWidget {
  final Future<void> Function(String password) onConfirm;
  final Function(String error) onError;

  const _PasswordConfirmationDialog({
    required this.onConfirm,
    required this.onError,
  });

  @override
  State<_PasswordConfirmationDialog> createState() =>
      _PasswordConfirmationDialogState();
}

class _PasswordConfirmationDialogState
    extends State<_PasswordConfirmationDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onConfirm(_passwordController.text);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      widget.onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        title: const Text('Confirm Password'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please enter your password to confirm account deletion:',
                    style: TextStyle(fontSize: 14),
                  ),
                  AppSpacing.v16,
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isLoading ? null : _confirm,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
