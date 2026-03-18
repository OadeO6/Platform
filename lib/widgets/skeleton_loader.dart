import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Skeleton loading states for Platform screens.
/// Uses shimmer effect. No spinners for primary content.
///
/// Usage:
/// ```dart
/// SkeletonLoader.feedGrid()      // 2-column feed grid skeleton
/// SkeletonLoader.feedList()      // Single-column feed list skeleton
/// SkeletonLoader.itemDetail()    // Full item detail skeleton
/// SkeletonLoader.mySpaceGrid()   // My Space grid skeleton
/// SkeletonLoader.box(width, height) // Generic shimmer box
/// ```
class SkeletonLoader extends StatelessWidget {
  final Widget child;

  const SkeletonLoader({super.key, required this.child});

  /// 2-column grid skeleton for home feed
  static Widget feedGrid({int itemCount = 6}) {
    return _ShimmerWrapper(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => const _FeedCardSkeleton(),
      ),
    );
  }

  /// Single-column list skeleton for home feed
  static Widget feedList({int itemCount = 4}) {
    return _ShimmerWrapper(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const _FeedListSkeleton(),
      ),
    );
  }

  /// Full item detail screen skeleton
  static Widget itemDetail() {
    return _ShimmerWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery
          const _SkeletonBox(width: double.infinity, height: 320),
          const SizedBox(height: 20),
          // Content
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: double.infinity, height: 32),
                SizedBox(height: 8),
                _SkeletonBox(width: 180, height: 24),
                SizedBox(height: 20),
                _SkeletonBox(width: 100, height: 16),
                SizedBox(height: 6),
                _SkeletonBox(width: double.infinity, height: 16),
                SizedBox(height: 6),
                _SkeletonBox(width: double.infinity, height: 16),
                SizedBox(height: 6),
                _SkeletonBox(width: 200, height: 16),
                SizedBox(height: 24),
                _SkeletonBox(width: double.infinity, height: 72, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Generic shimmer box for custom layouts
  static Widget box({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return _ShimmerWrapper(
      child: _SkeletonBox(width: width, height: height, radius: radius),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrapper(child: child);
  }
}

/// Wraps children in Shimmer effect, theme-aware
class _ShimmerWrapper extends StatelessWidget {
  final Widget child;
  const _ShimmerWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark
          ? AppColors.darkDivider
          : AppColors.divider,
      highlightColor: isDark
          ? AppColors.darkSurface
          : AppColors.surface,
      child: child,
    );
  }
}

/// A plain grey box — the base of all skeleton shapes
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton for a single feed grid card
class _FeedCardSkeleton extends StatelessWidget {
  const _FeedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        const Expanded(
          child: _SkeletonBox(width: double.infinity, height: double.infinity),
        ),
        const SizedBox(height: 8),
        // Title
        const _SkeletonBox(width: double.infinity, height: 14),
        const SizedBox(height: 6),
        // Price
        const _SkeletonBox(width: 80, height: 12),
        const SizedBox(height: 6),
        // Location
        const _SkeletonBox(width: 60, height: 10),
      ],
    );
  }
}

/// Skeleton for a single feed list row
class _FeedListSkeleton extends StatelessWidget {
  const _FeedListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _SkeletonBox(width: 100, height: 100),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SkeletonBox(width: double.infinity, height: 14),
              SizedBox(height: 8),
              _SkeletonBox(width: 100, height: 12),
              SizedBox(height: 8),
              _SkeletonBox(width: 80, height: 10),
              SizedBox(height: 8),
              _SkeletonBox(width: 60, height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
