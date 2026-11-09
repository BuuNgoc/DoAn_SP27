import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
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

/// Tab 5 – "Cá nhân" [FE-01, FE-07, FE-08, FE-09, FE-10, LI-06]
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.state.user);
    final currentLang = context.watch<LocaleCubit>().currentOption;

    return TopographicScaffold(
      seed: 89,
      appBar: CustomAppBar(title: context.tr('profile.title'), showBackButton: false),
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
            _GroupLabel(context.tr('profile.section_my_activity')),
            _MenuGroup(children: [
              ProfileMenuTile(
                icon: Icons.confirmation_number_rounded,
                title: context.tr('profile.booking_history_title'),
                subtitle: context.tr('profile.booking_history_subtitle'),
                onTap: () => context.push(RouteNames.bookingHistory),
              ),
              ProfileMenuTile(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.error,
                title: context.tr('profile.saved_favorites_title'),
                subtitle: context.tr('profile.saved_favorites_subtitle'),
                onTap: () => context.push(RouteNames.favorites),
              ),
              ProfileMenuTile(
                icon: Icons.rate_review_rounded,
                iconColor: AppColors.accentSoftGold,
                title: context.tr('profile.my_reviews_title'),
                subtitle: context.tr('profile.my_reviews_subtitle'),
                onTap: () => context.push(RouteNames.myReviews),
              ),
              ProfileMenuTile(
                icon: Icons.qr_code_scanner_rounded,
                title: context.tr('profile.checkin_history_title'),
                subtitle: context.tr('profile.checkin_history_subtitle'),
                onTap: () => context.push(RouteNames.checkin),
              ),
            ]),
            const SizedBox(height: 16),
            _GroupLabel(context.tr('profile.section_account_security')),
            _MenuGroup(children: [
              ProfileMenuTile(
                icon: Icons.manage_accounts_rounded,
                title: context.tr('profile.edit_profile_title'),
                subtitle: context.tr('profile.edit_profile_subtitle'),
                onTap: () => context.push(RouteNames.editProfile),
              ),
              ProfileMenuTile(
                icon: Icons.lock_reset_rounded,
                title: context.tr('profile.change_password_title'),
                subtitle: context.tr('profile.change_password_subtitle'),
                onTap: () => context.push(RouteNames.changePassword),
              ),
            ]),
          ] else ...[
            _GroupLabel(context.tr('profile.section_guest_explore')),
            _MenuGroup(children: [
              ProfileMenuTile(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.error,
                title: context.tr('profile.saved_favorites_title'),
                subtitle: context.tr('profile.saved_favorites_guest_subtitle'),
                onTap: () => context.push(RouteNames.favorites),
              ),
              ProfileMenuTile(
                icon: Icons.redeem_rounded,
                iconColor: AppColors.accentSoftGold,
                title: context.tr('profile.rewards_title'),
                subtitle: context.tr('profile.rewards_subtitle'),
                onTap: () => context.push(RouteNames.rewards),
              ),
            ]),
          ],
          const SizedBox(height: 16),
          _GroupLabel(context.tr('profile.section_utilities')),
          _MenuGroup(children: [
            ProfileMenuTile(
              icon: Icons.translate_rounded,
              iconColor: AppColors.primaryTeal,
              title: context.tr('profile.language_title'),
              subtitle: context.tr('profile.language_subtitle'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${currentLang.flag} ${currentLang.nativeName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
              onTap: () => _LanguageSelectorSheet.show(context),
            ),
            ProfileMenuTile(
              icon: Icons.flight_land_rounded,
              title: context.tr('profile.airport_welcome_title'),
              subtitle: context.tr('profile.airport_welcome_subtitle'),
              onTap: () => context.push(RouteNames.airportWelcome),
            ),
            ProfileMenuTile(
              icon: Icons.ios_share_rounded,
              iconColor: AppColors.primaryPastel,
              title: context.tr('profile.share_app_title'),
              onTap: () => SocialShareSheet.show(
                context,
                title: context.tr('profile.share_app_subject'),
                message: context.tr('profile.share_app_message'),
              ),
            ),
            ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.textSecondary,
              title: context.tr('profile.about_app_title'),
              subtitle: context.tr('profile.about_app_subtitle'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: context.tr('app_name'),
                applicationVersion: '1.0.0',
                applicationLegalese: context.tr('profile.about_app_legalese'),
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
                  title: context.tr('profile.logout_confirm_title'),
                  message: context.tr('profile.logout_confirm_message'),
                  confirmLabel: context.tr('auth.logout'),
                  destructive: true,
                );
                if (!ok || !context.mounted) return;
                await context.read<AuthCubit>().logout();
                if (context.mounted) {
                  showAppSnackBar(context, context.tr('profile.logout_success'));
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.tr('auth.logout')),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet chọn 4 ngôn ngữ (LI-06: vi, en, ko, zh).
class _LanguageSelectorSheet extends StatelessWidget {
  const _LanguageSelectorSheet();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = context.watch<LocaleCubit>().currentLanguageCode;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('profile.language_sheet_title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('profile.language_sheet_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final option in LocaleCubit.supportedOptions) ...[
                _LanguageOptionTile(
                  option: option,
                  selected: option.code == currentCode,
                  onSelect: () async {
                    await context.read<LocaleCubit>().setLocale(option.code);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.option,
    required this.selected,
    required this.onSelect,
  });

  final SupportedLanguageOption option;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.backgroundSecondary : AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primaryTeal : AppColors.cardBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(option.flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.nativeName,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.primaryTeal : AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal, size: 22)
              else
                const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
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
          Text(
            context.tr('profile.guest_greeting'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('profile.guest_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push(RouteNames.register),
                  child: Text(context.tr('auth.register')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push('${RouteNames.login}?from=${RouteNames.profile}'),
                  child: Text(context.tr('auth.login')),
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

  String _roleLabel(BuildContext context) {
    if (user.isAdmin) return context.tr('profile.role_admin');
    if (user.isTourismManager) return context.tr('profile.role_manager');
    return context.tr('profile.role_tourist');
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
                    PillBadge(label: _roleLabel(context), color: _roleColor, fontSize: 10.5),
                    PillBadge(label: user.nationality, icon: Icons.public_rounded, fontSize: 10.5),
                    if (user.createdAt != null)
                      PillBadge(
                        label: context.tr(
                          'profile.member_since',
                          params: {'date': DateFormatter.formatDateOnly(user.createdAt!)},
                        ),
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('profile.edit_profile_tooltip'),
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
                    Text(
                      context.tr('profile.loyalty_card_title'),
                      style: const TextStyle(
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
                        Flexible(
                          child: Text(
                            context.tr('profile.available_points'),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8A620F),
                            ),
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
                label: Text(
                  context.tr('profile.redeem_button'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
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
                Text(
                  context.tr('profile.lifetime_points_label'),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                Text(
                  context.tr(
                    'profile.points_With_unit',
                    params: {'points': '${user.totalEarnedPoints}'},
                  ),
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
          _Stat(
            value: '${loyalty.collectedPointIds.length}',
            label: context.tr('profile.stat_checkin'),
          ),
          _Stat(
            value: '$favorites',
            label: context.tr('profile.stat_favorites'),
          ),
          _Stat(
            value: '${loyalty.redemptions.length}',
            label: context.tr('profile.stat_redeemed'),
          ),
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
