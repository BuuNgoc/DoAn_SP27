import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../domain/entities/loyalty_entities.dart';

/// Thẻ tổng điểm + tiến trình hạng thành viên (tông vàng nhấn Loyalty).
class PointsSummaryCard extends StatelessWidget {
  const PointsSummaryCard({super.key, required this.summary, this.onTap});

  final LoyaltySummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tier = summary.tier;
    final next = tier.next;
    return AppCard(
      gradient: AppColors.goldGradient,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tier.icon, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(tier.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.stars_rounded, color: Colors.white, size: 26),
            ],
          ),
          const SizedBox(height: 14),
          Text(context.tr('loyalty.available_points_label'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: summary.availablePoints.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => Text(
              context.tr('loyalty.points_with_unit', params: {'points': CurrencyFormatter.points(v.round())}),
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: summary.tierProgress,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next == null
                ? context.tr('loyalty.highest_tier_reached')
                : context.tr(
                    'loyalty.points_to_next_tier',
                    params: {
                      'points': CurrencyFormatter.points(summary.pointsToNextTier),
                      'tier': next.label,
                    },
                  ),
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class RewardCard extends StatelessWidget {
  const RewardCard({super.key, required this.reward, required this.availablePoints, this.width});

  final Reward reward;
  final int availablePoints;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final affordable = availablePoints >= reward.pointsCost;
    return SizedBox(
      width: width,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push(RouteNames.rewardDetail(reward.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: CoverImage(source: reward.image, radius: 0),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: PillBadge(
                      label: reward.category.label,
                      icon: reward.category.icon,
                      color: AppColors.textPrimary,
                      background: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10.5,
                    ),
                  ),
                  if (!reward.inStock)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.tr('loyalty.out_of_stock'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.3)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.accentSoftGold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyFormatter.points(reward.pointsCost),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: affordable ? AppColors.accentSoftGold : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
