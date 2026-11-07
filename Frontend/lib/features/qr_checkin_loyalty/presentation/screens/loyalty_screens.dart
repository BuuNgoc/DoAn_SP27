import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/auth_guard.dart';
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
import '../widgets/loyalty_widgets.dart';

/// [FE-09] Danh sách quà tặng & tổng điểm tích lũy.
class LoyaltyRewardsScreen extends StatefulWidget {
  const LoyaltyRewardsScreen({super.key});

  @override
  State<LoyaltyRewardsScreen> createState() => _LoyaltyRewardsScreenState();
}

class _LoyaltyRewardsScreenState extends State<LoyaltyRewardsScreen> {
  RewardCategory? _category;

  @override
  Widget build(BuildContext context) {
    final isAuth = context.select((AuthCubit c) => c.state.isAuthenticated);
    return TopographicScaffold(
      seed: 47,
      appBar: CustomAppBar(
        title: 'Đổi điểm lấy quà',
        actions: [
          CircleIconButton(
            icon: Icons.receipt_long_rounded,
            tooltip: 'Lịch sử đổi thưởng',
            onPressed: () => context.push(RouteNames.redemptionHistory),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<LoyaltyCubit, LoyaltyState>(
        builder: (context, state) {
          if (state.rewards.isEmpty && state.status.isLoading) return const LoadingIndicator();
          final rewards = state.rewards.where((r) => _category == null || r.category == _category).toList();
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAuth)
                        PointsSummaryCard(summary: state.summary)
                      else
                        AppCard(
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Đăng nhập để xem điểm tích lũy và đổi quà.',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              TextButton(
                                onPressed: () => context.push('${RouteNames.login}?from=${RouteNames.rewards}'),
                                child: const Text('Đăng nhập'),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      _TierLadder(current: state.summary.tier),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Tất cả'),
                            selected: _category == null,
                            onSelected: (_) => setState(() => _category = null),
                          ),
                          for (final c in RewardCategory.values)
                            ChoiceChip(
                              avatar: Icon(c.icon, size: 16),
                              label: Text(c.label),
                              selected: _category == c,
                              onSelected: (_) => setState(() => _category = c),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => RewardCard(reward: rewards[i], availablePoints: state.summary.availablePoints),
                    childCount: rewards.length,
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

class _TierLadder extends StatelessWidget {
  const _TierLadder({required this.current});
  final MemberTier current;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          for (final t in MemberTier.values)
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: t.index <= current.index ? t.color : AppColors.backgroundSecondary,
                    child: Icon(t.icon, size: 20, color: t.index <= current.index ? Colors.white : AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(t.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: t == current ? FontWeight.w800 : FontWeight.w500,
                        color: t == current ? AppColors.textPrimary : AppColors.textSecondary,
                      )),
                  Text('${CurrencyFormatter.points(t.minPoints)}+',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// [FE-09] Chi tiết phần thưởng và đổi điểm.
class RewardDetailScreen extends StatelessWidget {
  const RewardDetailScreen({super.key, required this.rewardId});

  final String rewardId;

  Future<void> _redeem(BuildContext context, Reward reward) async {
    final user = await requireLogin(context, reason: 'Vui lòng đăng nhập để đổi quà.');
    if (user == null || !context.mounted) return;
    final available = context.read<LoyaltyCubit>().state.summary.availablePoints;
    if (available < reward.pointsCost) {
      showAppSnackBar(
        context,
        'Bạn cần thêm ${CurrencyFormatter.points(reward.pointsCost - available)} điểm để đổi quà này.',
        type: SnackType.warning,
      );
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: 'Xác nhận đổi quà',
      message: 'Dùng ${CurrencyFormatter.points(reward.pointsCost)} điểm để đổi “${reward.title}”?',
      confirmLabel: 'Đổi quà',
    );
    if (!ok || !context.mounted) return;
    final outcome = await context.read<LoyaltyCubit>().redeem(reward.id);
    if (!context.mounted) return;
    if (outcome.redemption == null) {
      showAppSnackBar(context, outcome.error ?? 'Đổi quà không thành công.', type: SnackType.error);
      return;
    }
    await RedemptionCodeSheet.show(context, outcome.redemption!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoyaltyCubit, LoyaltyState>(
      builder: (context, state) {
        final reward = state.rewards.where((r) => r.id == rewardId).firstOrNull;
        if (reward == null) {
          return TopographicScaffold(
            appBar: const CustomAppBar(title: 'Chi tiết quà tặng'),
            body: state.status.isLoading
                ? const LoadingIndicator()
                : const EmptyStateWidget(
                    icon: Icons.redeem_rounded,
                    title: 'Không tìm thấy quà tặng',
                    message: 'Quà tặng có thể đã ngừng chương trình.',
                  ),
          );
        }
        final available = state.summary.availablePoints;
        final affordable = available >= reward.pointsCost;
        return TopographicScaffold(
          seed: 53,
          appBar: CustomAppBar(
            title: 'Chi tiết quà tặng',
            actions: [
              CircleIconButton(
                icon: Icons.ios_share_rounded,
                tooltip: 'Chia sẻ',
                onPressed: () => SocialShareSheet.show(
                  context,
                  title: reward.title,
                  message: 'Đổi điểm SmartTravel lấy “${reward.title}” – ${reward.partner}. '
                      'Check-in khám phá Ngũ Hành Sơn để tích điểm nhé! #SmartTravel #NguHanhSon',
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              CoverImage(source: reward.image, height: 220, width: double.infinity, radius: 22),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PillBadge(label: reward.category.label, icon: reward.category.icon),
                  PillBadge(
                    label: reward.inStock ? 'Còn ${reward.stock} phần quà' : 'Tạm hết quà',
                    icon: Icons.inventory_2_rounded,
                    color: reward.inStock ? AppColors.success : AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(reward.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.accentSoftGold),
                  const SizedBox(width: 6),
                  Text('${CurrencyFormatter.points(reward.pointsCost)} điểm',
                      style: const TextStyle(
                          color: AppColors.accentSoftGold, fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 14),
              Text(reward.description, style: const TextStyle(height: 1.55, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.storefront_rounded, label: 'Đối tác', value: reward.partner),
                    const Divider(height: 20),
                    _InfoRow(icon: Icons.place_rounded, label: 'Nơi nhận quà', value: reward.pickupLocation),
                  ],
                ),
              ),
              if (reward.terms.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Điều kiện áp dụng', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                for (final t in reward.terms)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryTeal),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t, style: const TextStyle(height: 1.45))),
                      ],
                    ),
                  ),
              ],
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Điểm của bạn', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Text(CurrencyFormatter.points(available),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: affordable ? AppColors.textPrimary : AppColors.error,
                            )),
                      ],
                    ),
                  ),
                  CustomButton(
                    label: reward.inStock ? 'Đổi quà ngay' : 'Tạm hết quà',
                    icon: Icons.redeem_rounded,
                    gold: true,
                    expanded: false,
                    isLoading: state.busy,
                    onPressed: reward.inStock ? () => _redeem(context, reward) : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryTeal),
        const SizedBox(width: 10),
        SizedBox(width: 92, child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }
}

/// Bottom sheet hiển thị mã nhận quà (QR + mã chữ).
class RedemptionCodeSheet extends StatelessWidget {
  const RedemptionCodeSheet({super.key, required this.redemption});

  final Redemption redemption;

  static Future<void> show(BuildContext context, Redemption redemption) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: AppColors.surfaceWhite,
        builder: (_) => RedemptionCodeSheet(redemption: redemption),
      );

  @override
  Widget build(BuildContext context) {
    final r = redemption;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(r.rewardTitle,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            PillBadge(label: r.status.label, color: r.status.color),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: QrImageView(
                data: 'SMARTTRAVEL|REDEEM|${r.code}',
                size: 180,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.textPrimary),
                dataModuleStyle:
                    const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Clipboard.setData(ClipboardData(text: r.code));
                showAppSnackBar(context, 'Đã sao chép mã nhận quà.', type: SnackType.success);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(r.code,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy_rounded, size: 18, color: AppColors.primaryTeal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Xuất trình mã tại: ${r.pickupLocation}\nHạn nhận quà: ${DateFormatter.formatDateOnly(r.expiresAt)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 18),
            CustomButton(label: 'Hoàn tất', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

/// [FE-09] Lịch sử đổi thưởng.
class RedemptionHistoryScreen extends StatelessWidget {
  const RedemptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TopographicScaffold(
      seed: 59,
      appBar: const CustomAppBar(title: 'Lịch sử đổi thưởng'),
      body: BlocBuilder<LoyaltyCubit, LoyaltyState>(
        builder: (context, state) {
          if (state.status.isLoading && state.redemptions.isEmpty) return const LoadingIndicator();
          if (state.redemptions.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.redeem_rounded,
              title: 'Bạn chưa đổi quà nào',
              message: 'Tích điểm qua check-in QR và đổi lấy quà lưu niệm đá Non Nước hoặc voucher hấp dẫn.',
              actionLabel: 'Xem quà tặng',
              onAction: () => context.push(RouteNames.rewards),
            );
          }
          final spent = state.redemptions.fold<int>(0, (s, r) => s + r.pointsSpent);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(label: 'Lượt đổi quà', value: '${state.redemptions.length}'),
                    ),
                    Container(width: 1, height: 36, color: AppColors.cardBorder),
                    Expanded(child: _Stat(label: 'Điểm đã dùng', value: CurrencyFormatter.points(spent))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final r in state.redemptions) ...[
                AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => RedemptionCodeSheet.show(context, r),
                  child: Row(
                    children: [
                      CoverImage(source: r.rewardImage, width: 64, height: 64, radius: 14),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.rewardTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Mã: ${r.code} · ${DateFormatter.formatDateOnly(r.redeemedAt)}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                            const SizedBox(height: 6),
                            PillBadge(label: r.status.label, color: r.status.color, fontSize: 10.5),
                          ],
                        ),
                      ),
                      Text('-${CurrencyFormatter.points(r.pointsSpent)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.error)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
      ],
    );
  }
}
