import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../domain/entities/loyalty_entities.dart';
import '../bloc/loyalty_cubit.dart';

/// [FE-08] Bộ sưu tập điểm check-in Ngũ Hành Sơn & lịch sử check-in.
class CheckinPointsScreen extends StatelessWidget {
  const CheckinPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: TopographicScaffold(
        seed: 31,
        appBar: const CustomAppBar(
          title: 'Bộ sưu tập check-in',
          bottom: TabBar(
            tabs: [Tab(text: 'Điểm check-in'), Tab(text: 'Lịch sử')],
          ),
        ),
        body: BlocBuilder<LoyaltyCubit, LoyaltyState>(
          builder: (context, state) {
            if (state.points.isEmpty && state.status.isLoading) return const LoadingIndicator();
            return TabBarView(
              children: [
                _CollectionTab(state: state),
                _HistoryTab(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CollectionTab extends StatelessWidget {
  const _CollectionTab({required this.state});
  final LoyaltyState state;

  @override
  Widget build(BuildContext context) {
    final collected = state.collectedPointIds;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          sliver: SliverToBoxAdapter(
            child: AppCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: state.collectionProgress,
                          strokeWidth: 7,
                          backgroundColor: AppColors.backgroundSecondary,
                        ),
                        Center(
                          child: Text('${(state.collectionProgress * 100).round()}%',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đã sưu tầm ${collected.length}/${state.points.length} địa điểm',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                        const SizedBox(height: 4),
                        const Text(
                          'Hoàn thành bộ sưu tập để nhận huy hiệu “Người giữ hồn đá Ngũ Hành”.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = state.points[i];
                return _CheckinPointCard(point: p, collected: collected.contains(p.id));
              },
              childCount: state.points.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckinPointCard extends StatelessWidget {
  const _CheckinPointCard({required this.point, required this.collected});
  final CheckinPoint point;
  final bool collected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => _showDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Opacity(
                    opacity: collected ? 1 : 0.55,
                    child: CoverImage(source: point.image, radius: 0),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: collected
                      ? const PillBadge(label: 'Đã check-in', icon: Icons.verified_rounded, color: AppColors.success, solid: true, fontSize: 10.5)
                      : PillBadge(
                          label: 'Chưa ghé',
                          icon: Icons.lock_outline_rounded,
                          color: AppColors.textSecondary,
                          background: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10.5,
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
                Text(point.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.25)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 16, color: AppColors.accentSoftGold),
                    const SizedBox(width: 4),
                    Text('+${point.points} điểm',
                        style: const TextStyle(color: AppColors.accentSoftGold, fontWeight: FontWeight.w800, fontSize: 12.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceWhite,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(source: point.image, height: 150, width: double.infinity, radius: 18),
              const SizedBox(height: 14),
              Text(point.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 16, color: AppColors.primaryTeal),
                  const SizedBox(width: 4),
                  Expanded(child: Text(point.area, style: const TextStyle(color: AppColors.textSecondary))),
                ],
              ),
              const SizedBox(height: 10),
              Text(point.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (point.destinationId != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push(RouteNames.destinationDetail(point.destinationId!));
                        },
                        child: const Text('Xem điểm đến'),
                      ),
                    ),
                  if (point.destinationId != null) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: collected
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              context.push(RouteNames.qrScanner);
                            },
                      icon: Icon(collected ? Icons.check_rounded : Icons.qr_code_scanner_rounded),
                      label: Text(collected ? 'Đã check-in' : 'Quét mã QR'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.state});
  final LoyaltyState state;

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select((AuthCubit c) => c.state.isAuthenticated);
    if (!isAuth) {
      return EmptyStateWidget(
        icon: Icons.lock_person_rounded,
        title: 'Đăng nhập để xem lịch sử',
        message: 'Lịch sử check-in được lưu theo tài khoản của bạn.',
        actionLabel: 'Đăng nhập',
        onAction: () => context.push('${RouteNames.login}?from=${RouteNames.checkinPoints}'),
      );
    }
    if (state.history.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.qr_code_2_rounded,
        title: 'Chưa có lượt check-in nào',
        message: 'Hãy quét mã QR tại các điểm tham quan để bắt đầu bộ sưu tập.',
        actionLabel: 'Quét mã ngay',
        onAction: () => context.push(RouteNames.qrScanner),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: state.history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final h = state.history[i];
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.where_to_vote_rounded, color: AppColors.primaryTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.pointName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(DateFormatter.formatFull(h.checkedInAt),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  ],
                ),
              ),
              Text('+${h.pointsEarned}',
                  style: const TextStyle(color: AppColors.accentSoftGold, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }
}

/// [FE-08] Xác nhận check-in thành công: điểm nhận được, lên hạng, tiến độ bộ sưu tập.
class CheckinConfirmationScreen extends StatelessWidget {
  const CheckinConfirmationScreen({super.key, required this.result});

  final CheckinResult? result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) {
      return TopographicScaffold(
        appBar: const CustomAppBar(title: 'Check-in'),
        body: EmptyStateWidget(
          icon: Icons.qr_code_2_rounded,
          title: 'Không có dữ liệu check-in',
          message: 'Vui lòng quét lại mã QR tại điểm đến.',
          actionLabel: 'Quét mã QR',
          onAction: () => context.pushReplacement(RouteNames.qrScanner),
        ),
      );
    }
    return TopographicScaffold(
      seed: 41,
      appBar: const CustomAppBar(title: 'Check-in thành công'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                child: const Icon(Icons.where_to_vote_rounded, size: 60, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(r.point.name,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${r.point.area} · ${DateFormatter.formatFull(r.record.checkedInAt)}',
              textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          AppCard(
            gradient: AppColors.goldGradient,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: r.record.pointsEarned.toDouble()),
                        duration: const Duration(milliseconds: 900),
                        builder: (_, v, _) => Text('+${v.round()} điểm thưởng',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      ),
                      Text('Tổng điểm khả dụng: ${CurrencyFormatter.points(r.summary.availablePoints)}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (r.tierUpgraded) ...[
            const SizedBox(height: 14),
            AppCard(
              child: Row(
                children: [
                  Icon(r.summary.tier.icon, color: r.summary.tier.color, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chúc mừng! Bạn đã thăng hạng từ ${r.previousTier.label} lên ${r.summary.tier.label}.',
                      style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bộ sưu tập: ${r.collectedCount}/${r.totalPoints} địa điểm',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: r.totalPoints == 0 ? 0 : r.collectedCount / r.totalPoints,
                    minHeight: 8,
                    backgroundColor: AppColors.backgroundSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(r.point.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          CustomButton(
            label: 'Chia sẻ thành tích',
            icon: Icons.ios_share_rounded,
            onPressed: () => SocialShareSheet.show(
              context,
              title: 'Check-in tại ${r.point.name}',
              message: 'Mình vừa check-in tại ${r.point.name} (Ngũ Hành Sơn, Đà Nẵng) và nhận '
                  '+${r.record.pointsEarned} điểm trên SmartTravel! '
                  'Bộ sưu tập: ${r.collectedCount}/${r.totalPoints} địa điểm. #SmartTravel #NguHanhSon',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pushReplacement(RouteNames.checkinPoints),
                  child: const Text('Xem bộ sưu tập'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pushReplacement(RouteNames.rewards),
                  child: const Text('Đổi quà'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
