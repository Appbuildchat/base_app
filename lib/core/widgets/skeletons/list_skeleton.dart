import 'package:flutter/material.dart';
import '../skeleton_loader.dart';
import '../../themes/color_theme.dart';
import '../../themes/app_theme.dart';
import '../../themes/app_shadows.dart';

class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool showAppBar;
  final String? title;

  const ListSkeleton({
    super.key,
    this.itemCount = 6,
    this.showAppBar = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppCommonColors.white.withValues(alpha: 0.0),
              elevation: 0,
              title: title != null
                  ? SkeletonLoader.rounded(width: 120, height: 20, radius: 4)
                  : null,
              leading: SkeletonLoader.rounded(width: 24, height: 24, radius: 4),
              actions: [
                SkeletonLoader.rounded(width: 24, height: 24, radius: 4),
                const SizedBox(width: 16),
              ],
            )
          : null,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: const SkeletonCard(),
          );
        },
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final bool showAppBar;

  const GridSkeleton({
    super.key,
    this.itemCount = 9,
    this.crossAxisCount = 2,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppCommonColors.white.withValues(alpha: 0.0),
              elevation: 0,
              title: SkeletonLoader.rounded(width: 120, height: 20, radius: 4),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: AppCommonColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.light,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image skeleton
                  Expanded(
                    flex: 3,
                    child: SkeletonLoader.rounded(
                      width: double.infinity,
                      height: double.infinity,
                      radius: 12,
                    ),
                  ),

                  // Content skeleton
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader.rounded(
                            width: double.infinity,
                            height: 16,
                            radius: 4,
                          ),
                          const SizedBox(height: 8),
                          SkeletonLoader.rounded(
                            width: 100,
                            height: 14,
                            radius: 4,
                          ),
                          const Spacer(),
                          SkeletonLoader.rounded(
                            width: 60,
                            height: 12,
                            radius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChatListSkeleton extends StatelessWidget {
  final int itemCount;

  const ChatListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppCommonColors.white.withValues(alpha: 0.0),
        elevation: 0,
        title: SkeletonLoader.rounded(width: 100, height: 20, radius: 4),
        actions: [
          SkeletonLoader.rounded(width: 24, height: 24, radius: 4),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppCommonColors.grey500.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                SkeletonLoader.circular(size: 50),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonLoader.rounded(
                            width: 120,
                            height: 16,
                            radius: 4,
                          ),
                          SkeletonLoader.rounded(
                            width: 50,
                            height: 12,
                            radius: 4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: SkeletonLoader.rounded(
                              width: double.infinity,
                              height: 14,
                              radius: 4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SkeletonLoader.circular(size: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FeedSkeleton extends StatelessWidget {
  final int itemCount;

  const FeedSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppCommonColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.light,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    SkeletonLoader.circular(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader.rounded(
                            width: 120,
                            height: 14,
                            radius: 4,
                          ),
                          const SizedBox(height: 4),
                          SkeletonLoader.rounded(
                            width: 80,
                            height: 12,
                            radius: 4,
                          ),
                        ],
                      ),
                    ),
                    SkeletonLoader.rounded(width: 24, height: 24, radius: 4),
                  ],
                ),

                const SizedBox(height: 16),

                // Content
                const SkeletonText(lines: 3),

                const SizedBox(height: 16),

                // Image placeholder
                SkeletonLoader.rounded(
                  width: double.infinity,
                  height: 200,
                  radius: 8,
                ),

                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SkeletonLoader.rounded(width: 60, height: 32, radius: 16),
                    SkeletonLoader.rounded(width: 60, height: 32, radius: 16),
                    SkeletonLoader.rounded(width: 60, height: 32, radius: 16),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
