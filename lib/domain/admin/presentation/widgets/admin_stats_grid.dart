import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_spacing.dart';
import 'admin_stat_card.dart';

class AdminStatsGrid extends StatelessWidget {
  final Map<String, int> userStats;
  final Map<String, int> feedbackStats;

  const AdminStatsGrid({
    super.key,
    required this.userStats,
    required this.feedbackStats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User Statistics Grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.m,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            AdminStatCard(
              title: 'Total Users',
              value: userStats['total'] ?? 0,
              color: AppColors.primary,
              icon: Icons.people,
            ),
            AdminStatCard(
              title: 'Admin Users',
              value: userStats['admins'] ?? 0,
              color: Colors.red,
              icon: Icons.admin_panel_settings,
            ),
          ],
        ),

        AppSpacing.v24,

        // Feedback Statistics Grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.m,
          mainAxisSpacing: AppSpacing.m,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            AdminStatCard(
              title: 'Total Reports',
              value: feedbackStats['total'] ?? 0,
              color: AppColors.secondary,
              icon: Icons.feedback,
            ),
            AdminStatCard(
              title: 'Pending',
              value: feedbackStats['pending'] ?? 0,
              color: AppCommonColors.orange,
              icon: Icons.pending,
            ),
          ],
        ),
      ],
    );
  }
}
