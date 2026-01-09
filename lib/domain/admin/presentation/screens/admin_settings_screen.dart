// This screen displays admin-specific settings and statistics
// Features:
// - Admin dashboard statistics
// - User count display
// - Reports/Feedback count display
// - Logout functionality
// - Clean, modern UI with theme system
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../functions/fetch_all_users.dart';
import '../../functions/fetch_all_feedbacks.dart';
import '../widgets/admin_info_section.dart';
import '../widgets/admin_stats_grid.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  Map<String, int> _userStats = {};
  Map<String, int> _feedbackStats = {};
  bool _isLoading = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      // Load user statistics
      final userResult = await getUserStatisticsForAdmin();
      if (userResult.isSuccess) {
        setState(() => _userStats = userResult.data!);
      }

      // Load feedback statistics
      final feedbackResult = await getFeedbackStatisticsForAdmin();
      if (feedbackResult.isSuccess) {
        setState(() => _feedbackStats = feedbackResult.data!);
      }
    } catch (e) {
      // Handle errors silently for statistics
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout Confirmation', style: AppTypography.headline3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTypography.bodyRegular,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCommonColors.red,
                    foregroundColor: AppCommonColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusS,
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      setState(() => _isLoggingOut = true);

      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          context.go('/auth/sign-in');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoggingOut = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading || _isLoggingOut,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CommonAppBar(
          title: 'Admin Settings',
          backgroundColor: AppCommonColors.white,
          foregroundColor: AppColors.text,
        ),
        body: SingleChildScrollView(
          padding: AppSpacing.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Info Section
              const AdminInfoSection()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.1, end: 0, duration: 600.ms),

              AppSpacing.v24,

              // Statistics Overview
              Text(
                    'Statistics Overview',
                    style: AppTypography.headline3.copyWith(
                      color: AppColors.text,
                    ),
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.1, end: 0, duration: 600.ms),

              AppSpacing.v16,

              // Statistics Grid
              AdminStatsGrid(
                    userStats: _userStats,
                    feedbackStats: _feedbackStats,
                  )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.1, end: 0, duration: 600.ms),

              AppSpacing.v32,

              // Divider
              const Divider(thickness: 1, color: Colors.grey),

              AppSpacing.v24,

              // Logout Button
              SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCommonColors.red,
                        foregroundColor: AppCommonColors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderRadiusM,
                        ),
                      ),
                    ),
                  )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms),

              AppSpacing.v40,
            ],
          ),
        ),
      ),
    );
  }
}
