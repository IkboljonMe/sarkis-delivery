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

/// Admin order cards: #id + status badge, customer row, address, footer.
class OrderListSkeleton extends StatelessWidget {
  final int count;
  const OrderListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: count,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  SBox(width: 70, height: 16),
                  Spacer(),
                  SBox(width: 90, height: 22, radius: 11),
                ]),
                SizedBox(height: 12),
                SBox(width: 200, height: 14),
                SizedBox(height: 8),
                SBox(height: 12),
                SizedBox(height: 12),
                Row(children: [
                  SBox(width: 120, height: 12),
                  Spacer(),
                  SBox(width: 70, height: 16),
                ]),
              ],
            ),
          ),
        ),
      );
}

/// Vertical list of simple cards (approvals, coupons, shifts, groups,
/// customers). Each card has a title line and a couple of detail lines.
class SimpleCardListSkeleton extends StatelessWidget {
  final int count;
  final double cardHeight;
  const SimpleCardListSkeleton({super.key, this.count = 6, this.cardHeight = 84});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: count,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SBox(height: cardHeight, radius: 16),
          ),
        ),
      );
}

/// Product rows: thumbnail + name/desc lines + price.
class ProductListSkeleton extends StatelessWidget {
  final int count;
  const ProductListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: count,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                SBox(width: 64, height: 64, radius: 12),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SBox(width: 140, height: 16),
                      SizedBox(height: 10),
                      SBox(height: 12),
                      SizedBox(height: 12),
                      SBox(width: 80, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Category rows (name + item count), a bit shorter than product rows.
class CategoryListSkeleton extends StatelessWidget {
  final int count;
  const CategoryListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: count,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                SBox(width: 44, height: 44, radius: 10),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SBox(width: 160, height: 15),
                      SizedBox(height: 8),
                      SBox(width: 90, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Chat list rows: avatar + name/preview lines + time.
class ChatListSkeleton extends StatelessWidget {
  final int count;
  const ChatListSkeleton({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: count,
          itemBuilder: (_, __) => const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                SBox(width: 52, height: 52, radius: 26),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SBox(width: 140, height: 15),
                      SizedBox(height: 10),
                      SBox(height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                SBox(width: 40, height: 12),
              ],
            ),
          ),
        ),
      );
}

/// Dashboard: summary stat cards grid + a short recent-orders list.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: List.generate(
                4,
                (_) => const SBox(height: double.infinity, radius: 16),
              ),
            ),
            const SizedBox(height: 24),
            const SBox(width: 160, height: 18),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SBox(height: 72, radius: 16),
              ),
            ),
          ],
        ),
      );
}

/// Report cards: a few stacked stat/summary blocks.
class ReportCardsSkeleton extends StatelessWidget {
  const ReportCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmered(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SBox(height: 120, radius: 16),
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SBox(height: 64, radius: 16),
              ),
            ),
          ],
        ),
      );
}
