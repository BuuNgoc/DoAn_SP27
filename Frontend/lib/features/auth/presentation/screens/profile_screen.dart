import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../destination_discovery/presentation/bloc/destination_cubits.dart';
import '../../../qr_checkin_loyalty/presentation/bloc/loyalty_cubit.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

/// Tab 5 – "Cá nhân" [FE-01, FE-07, FE-08, FE-09, FE-10]
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.state.user);

    return TopographicScaffold(
      seed: 89,
      appBar: const CustomAppBar(title: 'Cá nhân', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, AppDimensions.bottomNavClearance),
        children: [
          if (user == null) const _GuestCard() else _UserHeader(user: user),
          const SizedBox(height: 16),
          if (user != null) ...[
            _LoyaltyPointsCard(user: user),
            const SizedBox(height: 16),
            const _StatsRow(),
            const SizedBox(height: 20),
            const _GroupLabel('Hoạt động của tôi'),
            _MenuGroup(children: [
              ProfileMenuTile(
                icon: Icons.confirmation_number_rounded,
                title: 'Lịch sử đặt chỗ',
                subtitle: 'Workshop, sự kiện, dịch vụ đã đặt',
                onTap: () => context.push(RouteNames.bookingHistory),
              ),
              ProfileMenuTile(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.error,
                title: 'Điểm đến yêu thích đã lưu',
                subtitle: 'Xem được cả khi ngoại tuyến',
                onTap: () => context.push(RouteNames.favorites),
              ),
              ProfileMenuTile(
                icon: Icons.rate_review_rounded,
                iconColor: AppColors.accentSoftGold,
                title: 'Đánh giá của tôi',
                subtitle: 'Xem lại các phản hồi & hình ảnh đã đăng',
                onTap: () => context.push(RouteNames.myReviews),
              ),
              ProfileMenuTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Lịch sử Check-in & Đổi quà',
                subtitle: 'Tích điểm tại các danh thắng & nhận quà lưu niệm',
                onTap: () => context.push(RouteNames.checkin),
              ),
            ]),
            const SizedBox(height: 16),
            const _GroupLabel('Tài khoản & Bảo mật'),
            _MenuGroup(children: [
              ProfileMenuTile(
                icon: Icons.manage_accounts_rounded,
                title: 'Chỉnh sửa hồ sơ',
                subtitle: 'Cập nhật họ tên, số điện thoại, ảnh đại diện',
                onTap: () => context.push(RouteNames.editProfile),
              ),
              ProfileMenuTile(
                icon: Icons.lock_reset_rounded,
                title: 'Đổi mật khẩu',
                subtitle: 'Bảo mật tài khoản của bạn',
                onTap: () => context.push(RouteNames.changePassword),
              ),
            ]),
          ] else ...[
            const _GroupLabel('Khám phá không cần đăng nhập'),
            _MenuGroup(children: [
              ProfileMenuTile(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.error,
                title: 'Điểm đến yêu thích đã lưu',
                subtitle: 'Lưu trên thiết bị, xem được khi ngoại tuyến',
                onTap: () => context.push(RouteNames.favorites),
              ),
              ProfileMenuTile(
                icon: Icons.redeem_rounded,
                iconColor: AppColors.accentSoftGold,
                title: 'Quà tặng đổi điểm',
                subtitle: 'Khám phá các sản phẩm đá Non Nước độc đáo',
                onTap: () => context.push(RouteNames.rewards),
              ),
            ]),
          ],
          const SizedBox(height: 16),
          const _GroupLabel('Tiện ích & Ứng dụng'),
          _MenuGroup(children: [
            ProfileMenuTile(
              icon: Icons.flight_land_rounded,
              title: 'Chào mừng từ sân bay',
              subtitle: 'Giới thiệu nhanh Ngũ Hành Sơn cho khách du lịch',
              onTap: () => context.push(RouteNames.airportWelcome),
            ),
            ProfileMenuTile(
              icon: Icons.ios_share_rounded,
              iconColor: AppColors.primaryPastel,
              title: 'Giới thiệu SmartTravel cho bạn bè',
              onTap: () => SocialShareSheet.show(
                context,
                title: 'SmartTravel – Ngũ Hành Sơn',
                message:
                    'Khám phá Ngũ Hành Sơn với SmartTravel: VR360, thuyết minh đa ngôn ngữ, lịch trình AI, check-in QR đổi quà đá Non Nước! #SmartTravel #NguHanhSon',
              ),
            ),
            ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.textSecondary,
              title: 'Về ứng dụng SmartTravel',
              subtitle: 'Phiên bản 1.0.0 · Nhóm SE13',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'SmartTravel – Ngũ Hành Sơn',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Đồ án Nhóm SE13 – Nền tảng du lịch thông minh Ngũ Hành Sơn, Đà Nẵng.',
              ),
            ),
          ]),
          if (user != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: 'Đăng xuất?',
                  message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?',
                  confirmLabel: 'Đăng xuất',
                  destructive: true,
                );
                if (!ok || !context.mounted) return;
                await context.read<AuthCubit>().logout();
                if (context.mounted) {
                  showAppSnackBar(context, 'Bạn đã đăng xuất thành công. Hẹn gặp lại!');
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất'),
            ),
          ],
        ],
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.backgroundSecondary,
            child: Icon(Icons.person_outline_rounded, size: 38, color: AppColors.primaryTeal),
          ),
          const SizedBox(height: 12),
          const Text('Xin chào du khách!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Đăng nhập để đặt chỗ workshop điêu khắc đá, tích điểm check-in đổi quà lưu niệm và viết đánh giá.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push(RouteNames.register),
                  child: const Text('Đăng ký'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push('${RouteNames.login}?from=${RouteNames.profile}'),
                  child: const Text('Đăng nhập'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});
  final UserEntity user;

  String get _roleLabel {
    if (user.isAdmin) return 'Quản trị viên';
    if (user.isTourismManager) return 'Quản lý du lịch';
    return 'Du khách';
  }

  Color get _roleColor {
    if (user.isAdmin) return AppColors.error;
    if (user.isTourismManager) return AppColors.primaryTeal;
    return AppColors.accentSoftGold;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatarUrl;
    final hasAvatar = avatar != null && avatar.trim().isNotEmpty;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasAvatar ? null : AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: hasAvatar
                  ? CachedNetworkImage(
                      imageUrl: avatar,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.backgroundSecondary,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                if (user.phoneNumber.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(user.phoneNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PillBadge(label: _roleLabel, color: _roleColor, fontSize: 10.5),
                    PillBadge(label: user.nationality, icon: Icons.public_rounded, fontSize: 10.5),
                    if (user.createdAt != null)
                      PillBadge(
                        label: 'Từ ${DateFormatter.formatDateOnly(user.createdAt!)}',
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Chỉnh sửa hồ sơ',
            onPressed: () => context.push(RouteNames.editProfile),
            icon: const Icon(Icons.edit_rounded, color: AppColors.primaryTeal),
          ),
        ],
      ),
    );
  }
}

/// Thẻ hiển thị Điểm tích lũy Loyalty Points tông màu vàng cát #E4B363
class _LoyaltyPointsCard extends StatelessWidget {
  const _LoyaltyPointsCard({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFBF4E6),
            AppColors.accentSoftGold.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentSoftGold.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentSoftGold.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentSoftGold,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentSoftGold.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.stars_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ĐIỂM THƯỞNG DU KHÁCH',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Color(0xFF946A14),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${user.loyaltyPoints}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7A5406),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'điểm khả dụng',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A620F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentSoftGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => context.push(RouteNames.rewards),
                icon: const Icon(Icons.redeem_rounded, size: 16),
                label: const Text('Đổi quà', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng điểm đã tích lũy trọn đời:',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                Text(
                  '${user.totalEarnedPoints} điểm',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A5406),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final loyalty = context.watch<LoyaltyCubit>().state;
    final favorites = context.watch<FavoritesCubit>().state.length;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          _Stat(value: '${loyalty.collectedPointIds.length}', label: 'Check-in QR'),
          _Stat(value: '$favorites', label: 'Yêu thích'),
          _Stat(value: '${loyalty.redemptions.length}', label: 'Quà đã đổi'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 13.5),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const Divider(height: 1, indent: 72, endIndent: 16),
          ],
        ],
      ),
    );
  }
}
