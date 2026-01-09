import 'package:flutter/material.dart';
import '../skeleton_loader.dart';
import '../../themes/app_theme.dart';
import '../../themes/app_shadows.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCommonColors.grey50,
      appBar: AppBar(
        title: SkeletonLoader.rounded(width: 140, height: 18, radius: 4),
        centerTitle: true,
        backgroundColor: AppCommonColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          SkeletonLoader.rounded(width: 24, height: 24, radius: 4),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile image with edit button
            Stack(
              children: [
                SkeletonLoader.circular(size: 120),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppCommonColors.grey300,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppCommonColors.white,
                        width: 3,
                      ),
                      boxShadow: AppShadows.medium,
                    ),
                    child: SkeletonLoader.rounded(
                      width: 18,
                      height: 18,
                      radius: 2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Info cards matching the actual ProfileScreen
            _buildInfoCardSkeleton('Username'),
            const SizedBox(height: 20),
            _buildInfoCardSkeleton('Bio'),
            const SizedBox(height: 20),
            _buildInfoCardSkeleton('Nickname'),
            const SizedBox(height: 20),
            _buildInfoCardSkeleton('Phone Number'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCardSkeleton(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppCommonColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.light,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader.rounded(width: 80, height: 12, radius: 4),
          const SizedBox(height: 8),
          SkeletonLoader.rounded(width: double.infinity, height: 16, radius: 4),
        ],
      ),
    );
  }
}
