import 'package:flutter/material.dart';
import '../../themes/color_theme.dart';
import '../skeleton_loader.dart';

class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SkeletonLoader.rounded(width: 70, height: 18, radius: 4),
        centerTitle: true,
        leading: SkeletonLoader.rounded(width: 24, height: 24, radius: 4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Settings Section
              const SizedBox(height: 8),
              _buildSettingTile('Change Username'),
              const SizedBox(height: 16),
              _buildSettingTile('Change Nickname'),
              const SizedBox(height: 16),
              _buildSettingTile('Change Phone Number'),
              const SizedBox(height: 16),
              _buildSettingTile('Change Bio'),
              const SizedBox(height: 16),
              _buildSettingTile('Change Password'),
              const SizedBox(height: 16),
              _buildSettingTile('Notification Settings'),
              const SizedBox(height: 16),
              _buildSettingTile('Send Feedback'),
              const SizedBox(height: 40),

              // Danger Zone Section
              _buildDangerTile('Log Out'),
              const SizedBox(height: 16),
              _buildDangerTile('Delete Account'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title) {
    return ListTile(
      leading: SkeletonLoader.rounded(width: 28, height: 28, radius: 4),
      title: SkeletonLoader.rounded(width: 150, height: 16, radius: 4),
      trailing: SkeletonLoader.rounded(width: 28, height: 28, radius: 4),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDangerTile(String title) {
    return ListTile(
      leading: SkeletonLoader.rounded(width: 28, height: 28, radius: 4),
      title: SkeletonLoader.rounded(width: 100, height: 16, radius: 4),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class SettingsFormSkeleton extends StatelessWidget {
  final String title;
  final int fieldCount;

  const SettingsFormSkeleton({
    super.key,
    required this.title,
    this.fieldCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkeletonLoader.rounded(width: 24, height: 24, radius: 4),
        title: SkeletonLoader.rounded(width: 120, height: 20, radius: 4),
        actions: [
          SkeletonLoader.rounded(width: 60, height: 32, radius: 16),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form description
            SkeletonLoader.rounded(
              width: double.infinity,
              height: 14,
              radius: 4,
            ),
            const SizedBox(height: 6),
            SkeletonLoader.rounded(width: 200, height: 14, radius: 4),

            const SizedBox(height: 32),

            // Form fields
            ...List.generate(
              fieldCount,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < fieldCount - 1 ? 20 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader.rounded(width: 80, height: 14, radius: 4),
                    const SizedBox(height: 8),
                    SkeletonLoader.rounded(
                      width: double.infinity,
                      height: 56,
                      radius: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            const SkeletonButton(width: double.infinity, height: 56),
          ],
        ),
      ),
    );
  }
}
