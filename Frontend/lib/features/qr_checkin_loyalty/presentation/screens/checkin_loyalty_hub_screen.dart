import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/loyalty_cubit.dart';
import '../widgets/loyalty_widgets.dart';

/// Tab 4 – "Check-in & Quà": tổng điểm, quét QR, bộ sưu tập check-in, đổi quà.
class CheckinLoyaltyHubScreen extends StatelessWidget {
  const CheckinLoyaltyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select((AuthCubit c) => c.state.isAuthenticated);
    return TopographicScaffold(
      seed: 23,
      appBar: CustomAppBar(
        title: context.tr('loyalty.hub_title'),
        subtitle: context.tr('loyalty.hub_subtitle'),
        showBackButton: false,
      ),
      body: BlocBuilder<LoyaltyCubit, LoyaltyState>(
        builder: (context, state) {
          if (state.status.isFailure && state.points.isEmpty) {
            return ErrorViewWidget(
              message: state.errorMessage ?? context.tr('loyalty.load_error'),
              onRetry: () => context.read<LoyaltyCubit>().load(context.read<AuthCubit>().state.user?.uid),
            );
          }
          if (state.points.isEmpty) return const LoadingIndicator();
          final collected = state.collectedPointIds;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, AppDimensions.bottomNavClearance),
            children: [
              if (isAuth)
                PointsSummaryCard(summary: state.summary, onTap: () => context.push(RouteNames.rewards))
              else
                AppCard(
                  gradient: AppColors.goldGradient,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('loyalty.guest_banner_title'),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('loyalty.guest_banner_subtitle'),
                        style: const TextStyle(color: Colors.white, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.accentSoftGold),
                        onPressed: () => context.push('${RouteNames.login}?from=${RouteNames.checkin}'),
                        child: Text(context.tr('auth.login_now')),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              CustomButton(
                label: context.tr('loyalty.scan_qr_checkin_btn'),
                icon: Icons.qr_code_scanner_rounded,
                onPressed: () => context.push(RouteNames.qrScanner),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _QuickAction(
                    icon: Icons.collections_bookmark_rounded,
                    label: context.tr('loyalty.action_collection'),
                    onTap: () => context.push(RouteNames.checkinPoints),
                  ),
                  _QuickAction(
                    icon: Icons.redeem_rounded,
                    label: context.tr('loyalty.action_redeem'),
                    color: AppColors.accentSoftGold,
                    onTap: () => context.push(RouteNames.rewards),
                  ),
                  _QuickAction(
                    icon: Icons.receipt_long_rounded,
                    label: context.tr('loyalty.action_history'),
                    onTap: () => context.push(RouteNames.redemptionHistory),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: context.tr('loyalty.collection_section_title'),
                subtitle: context.tr(
                  'loyalty.collection_section_subtitle',
                  params: {'collected': '${collected.length}', 'total': '${state.points.length}'},
                ),
                actionLabel: context.tr('common.view_all'),
                onAction: () => context.push(RouteNames.checkinPoints),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: state.collectionProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.backgroundSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 112,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.points.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final p = state.points[i];
                    final done = collected.contains(p.id);
                    return SizedBox(
                      width: 92,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ColorFiltered(
                                colorFilter: done
                                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                                    : const ColorFilter.matrix([
                                        0.33, 0.33, 0.33, 0, 0, //
                                        0.33, 0.33, 0.33, 0, 0,
                                        0.33, 0.33, 0.33, 0, 0,
                                        0, 0, 0, 0.6, 0,
                                      ]),
                                child: CoverImage(source: p.image, width: 72, height: 72, radius: 36),
                              ),
                              if (done)
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.success,
                                    child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(p.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                title: context.tr('loyalty.featured_rewards_title'),
                subtitle: context.tr('loyalty.featured_rewards_subtitle'),
                actionLabel: context.tr('common.all'),
                onAction: () => context.push(RouteNames.rewards),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.rewards.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => RewardCard(
                    reward: state.rewards[i],
                    availablePoints: state.summary.availablePoints,
                    width: 170,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.color = AppColors.primaryTeal});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          onTap: onTap,
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            ],
          ),
        ),
      ),
    );
  }
}
