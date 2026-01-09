import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_theme.dart';
import '../themes/app_shadows.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final double? radius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.radius,
    this.baseColor,
    this.highlightColor,
  });

  const SkeletonLoader.circular({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  }) : width = size,
       height = size,
       borderRadius = null,
       radius = null;

  const SkeletonLoader.rounded({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8.0,
    this.baseColor,
    this.highlightColor,
  }) : borderRadius = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppCommonColors.grey300,
      highlightColor: highlightColor ?? AppCommonColors.grey100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppCommonColors.white,
          borderRadius:
              borderRadius ??
              (radius != null
                  ? BorderRadius.circular(radius!)
                  : (width == height
                        ? BorderRadius.circular(width / 2)
                        : BorderRadius.circular(8))),
        ),
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final int lines;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final lineWidth = isLastLine && lines > 1 ? width * 0.7 : width;

        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 8 : 0),
          child: SkeletonLoader.rounded(
            width: lineWidth == double.infinity ? 200 : lineWidth,
            height: height,
            radius: 4,
          ),
        );
      }),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 140,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppCommonColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.button,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader.circular(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader.rounded(width: double.infinity, height: 14),
                    const SizedBox(height: 6),
                    SkeletonLoader.rounded(width: 150, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonText(lines: 2),
        ],
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final bool hasSubtitle;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.hasSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading) ...[
            const SkeletonLoader.circular(size: 40),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader.rounded(width: 180, height: 16),
                if (hasSubtitle) ...[
                  const SizedBox(height: 6),
                  SkeletonLoader.rounded(width: 120, height: 12),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16),
            SkeletonLoader.rounded(width: 24, height: 24),
          ],
        ],
      ),
    );
  }
}

class SkeletonButton extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonButton({super.key, this.width = 120, this.height = 45});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader.rounded(width: width, height: height, radius: 16);
  }
}
