import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_colors.dart';

/// Wraps a skeleton subtree in the app's dark shimmer. Put ONE of these at the
/// root of a skeleton; its children are plain [SBox]es (cheaper than shimmering
/// each box individually).
class Shimmered extends StatelessWidget {
  final Widget child;
  const Shimmered({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceElevated,
        child: child,
      );
}

/// A single grey placeholder block. `height: double.infinity` fills its parent.
class SBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SBox({super.key, this.width, this.height = 14, this.radius = 8});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Horizontal delivery-shift cards (Home "Deliveries" section — fills a 150h box).
class DeliveryCardsSkeleton extends StatelessWidget {
  const DeliveryCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Shimmered(
        child: _HList(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            SBox(width: 300, height: double.infinity, radius: 20),
            SizedBox(width: 12),
            SBox(width: 300, height: double.infinity, radius: 20),
          ],
        ),
      );
}

/// Round category previews (Home "Our products" row — fills a short box).
class CategoryCirclesSkeleton extends StatelessWidget {
  const CategoryCirclesSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: _HList(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(right: 20),
              child: SBox(width: 88, height: 88, radius: 44),
            ),
          ),
        ),
      );
}

/// Product rows: image + name/desc lines + price + qty stepper.
class ProductListSkeleton extends StatelessWidget {
  final int count;
  const ProductListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: count,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SBox(width: 72, height: 72, radius: 12),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SBox(width: 140, height: 16),
                      SizedBox(height: 10),
                      SBox(height: 12),
                      SizedBox(height: 6),
                      SBox(width: 190, height: 12),
                      SizedBox(height: 14),
                      SBox(width: 80, height: 16),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                SBox(width: 100, height: 36, radius: 18),
              ],
            ),
          ),
        ),
      );
}

/// 2-column square category tiles.
class CategoryGridSkeleton extends StatelessWidget {
  final int count;
  const CategoryGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: count,
          itemBuilder: (_, __) => DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
}

/// Order summary cards (#id + status, items line, date/total).
class OrderListSkeleton extends StatelessWidget {
  final int count;
  const OrderListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: count,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(children: [
                  SBox(width: 70, height: 16),
                  Spacer(),
                  SBox(width: 90, height: 24, radius: 12),
                ]),
                SizedBox(height: 12),
                SBox(height: 12),
                SizedBox(height: 8),
                Row(children: [
                  SBox(width: 90, height: 12),
                  Spacer(),
                  SBox(width: 60, height: 16),
                ]),
              ],
            ),
          ),
        ),
      );
}

/// Order-detail placeholder: status header, item rows, status timeline.
class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SBox(height: 90, radius: 16),
            const SizedBox(height: 20),
            const SBox(width: 140, height: 16),
            const SizedBox(height: 14),
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SBox(height: 64, radius: 12),
              ),
            ),
            const SizedBox(height: 10),
            const SBox(height: 130, radius: 16),
          ],
        ),
      );
}

/// Simple horizontal scroller used by the Home skeletons.
class _HList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  const _HList({required this.children, required this.padding});

  @override
  Widget build(BuildContext context) => ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
}
