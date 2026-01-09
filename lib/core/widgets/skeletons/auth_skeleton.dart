import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../skeleton_loader.dart';
import '../../themes/color_theme.dart';
import '../../themes/app_shadows.dart';

class AuthSkeleton extends StatelessWidget {
  const AuthSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title skeleton
              SkeletonLoader.rounded(width: 200, height: 32, radius: 8),

              const SizedBox(height: 8),

              // Subtitle skeleton
              SkeletonLoader.rounded(width: 300, height: 16, radius: 4),

              const SizedBox(height: 48),

              // Form fields skeleton
              Column(
                children: [
                  // Email field
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 56,
                    radius: 16,
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 56,
                    radius: 16,
                  ),

                  const SizedBox(height: 12),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: SkeletonLoader.rounded(
                      width: 120,
                      height: 14,
                      radius: 4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Button skeleton
                  const SkeletonButton(width: double.infinity, height: 56),
                ],
              ),

              const Spacer(),

              // Bottom text skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLoader.rounded(width: 140, height: 14, radius: 4),
                  const SizedBox(width: 4),
                  SkeletonLoader.rounded(width: 50, height: 14, radius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpSkeleton extends StatelessWidget {
  const SignUpSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title skeleton
              SkeletonLoader.rounded(width: 180, height: 32, radius: 8),

              const SizedBox(height: 8),

              // Subtitle skeleton
              SkeletonLoader.rounded(width: 160, height: 16, radius: 4),

              const SizedBox(height: 48),

              // Form fields skeleton
              Column(
                children: [
                  // Name field
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 56,
                    radius: 16,
                  ),

                  const SizedBox(height: 20),

                  // Email field
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 56,
                    radius: 16,
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 56,
                    radius: 16,
                  ),

                  const SizedBox(height: 20),

                  // Confirm password field
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 56,
                    radius: 16,
                  ),

                  const SizedBox(height: 20),

                  // Role dropdown
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 56,
                    radius: 16,
                  ),

                  const SizedBox(height: 32),

                  // Button skeleton
                  const SkeletonButton(width: double.infinity, height: 56),
                ],
              ),

              const SizedBox(height: 40),

              // Bottom text skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLoader.rounded(width: 120, height: 14, radius: 4),
                  const SizedBox(width: 4),
                  SkeletonLoader.rounded(width: 50, height: 14, radius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordSkeleton extends StatelessWidget {
  const ForgotPasswordSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Icon skeleton
              Center(child: SkeletonLoader.circular(size: 120)),

              const SizedBox(height: 40),

              // Title skeleton
              SkeletonLoader.rounded(width: 160, height: 32, radius: 8),

              const SizedBox(height: 12),

              // Description skeleton
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader.rounded(
                    width: double.infinity,
                    height: 14,
                    radius: 4,
                  ),
                  const SizedBox(height: 6),
                  SkeletonLoader.rounded(width: 250, height: 14, radius: 4),
                ],
              ),

              const SizedBox(height: 48),

              // Email field
              SkeletonLoader.rounded(
                width: double.infinity,
                height: 56,
                radius: 16,
              ),

              const SizedBox(height: 32),

              // Button skeleton
              const SkeletonButton(width: double.infinity, height: 56),

              const SizedBox(height: 48),

              // Bottom text skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonLoader.rounded(width: 150, height: 14, radius: 4),
                  const SizedBox(width: 4),
                  SkeletonLoader.rounded(width: 50, height: 14, radius: 4),
                ],
              ),

              const SizedBox(height: 40),

              // Info card skeleton
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppCommonColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.light,
                ),
                child: Row(
                  children: [
                    SkeletonLoader.circular(size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader.rounded(
                            width: double.infinity,
                            height: 12,
                            radius: 4,
                          ),
                          const SizedBox(height: 6),
                          SkeletonLoader.rounded(
                            width: 200,
                            height: 12,
                            radius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
