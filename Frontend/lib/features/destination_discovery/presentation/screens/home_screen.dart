import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';
import '../widgets/destination_widgets.dart';

/// [FE-02] Trang chủ – Tab "Khám phá".
/// Cửa ngõ tới FE-02, FE-03, FE-06, FE-12, FE-13, FE-14.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DestinationListCubit>()..load(),
      child: BlocListener<LocaleCubit, Locale>(
        listenWhen: (prev, curr) => prev.languageCode != curr.languageCode,
        listener: (context, _) => context.read<DestinationListCubit>().load(),
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.state.user);
    final greetingName =
        user == null ? context.tr('home.guest_name') : user.fullName.split(' ').last;

    return RefreshIndicator(
      color: AppColors.primaryTeal,
      onRefresh: () => context.read<DestinationListCubit>().load(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('home.greeting', params: {'name': greetingName}),
                            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('home.hero_title'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    _IconAction(
                      icon: Icons.favorite_border_rounded,
                      tooltip: context.tr('home.favorites_tooltip'),
                      onTap: () => context.push(RouteNames.favorites),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: RoundedSearchField(
                readOnly: true,
                onTap: () => context.push('${RouteNames.destinations}?focus=1'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CategoryFilterBar(
              selected: null,
              showAll: false,
              onSelected: (c) => context.push('${RouteNames.destinations}?category=${c?.code ?? ''}'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          const SliverToBoxAdapter(child: _AiPromoBanner()),
          const SliverToBoxAdapter(child: _RecentlyViewedSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: context.tr('home.featured_title'),
              subtitle: context.tr('home.featured_subtitle'),
              actionLabel: context.tr('common.view_all'),
              onAction: () => context.push(RouteNames.destinations),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: BlocBuilder<DestinationListCubit, DestinationListState>(
              builder: (context, state) {
                if (state.status.isLoading) {
                  return const SizedBox(height: 290, child: LoadingIndicator());
                }
                if (state.status.isFailure) {
                  return SizedBox(
                    height: 290,
                    child: ErrorViewWidget(
                      message: state.errorMessage ?? '',
                      onRetry: () => context.read<DestinationListCubit>().load(),
                    ),
                  );
                }
                final featured = [...state.items]..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
                return SizedBox(
                  height: 300,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    itemCount: featured.take(6).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => DestinationFeatureCard(destination: featured[i]),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: context.tr('home.zones_title'),
              subtitle: context.tr('home.zones_subtitle'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: _ExperienceZonesGrid()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: context.tr('home.immersive_title'),
              actionLabel: context.tr('common.see_more'),
              onAction: () => context.push(RouteNames.destinations),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          BlocBuilder<DestinationListCubit, DestinationListState>(
            builder: (context, state) {
              final immersive = state.items.where((d) => d.hasVr360 || d.hasAudioGuide).take(4).toList();
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: immersive.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => DestinationListTile(destination: immersive[i]),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.bottomNavClearance)),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap, required this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(width: 48, height: 48, child: Icon(icon, color: AppColors.primaryTeal)),
        ),
      ),
    );
  }
}

/// Thẻ quảng bá trợ lý AI lập lịch trình (FE-05 & RAG).
class _AiPromoBanner extends StatelessWidget {
  const _AiPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6F76), AppColors.primaryTeal, AppColors.primaryPastel],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: const EdgeInsets.all(18),
        onTap: () => context.push(RouteNames.aiPlanner),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoftGold,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.tr('home.ai_badge'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('home.ai_banner_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('home.ai_banner_subtitle'),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accentSoftGold, size: 34),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lưới truy cập nhanh các khu trải nghiệm.
class _ExperienceZonesGrid extends StatelessWidget {
  const _ExperienceZonesGrid();

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String title, String subtitle, Color color, String route})>[
      (
        icon: Icons.event_available_rounded,
        title: context.tr('home.zone_events_title'),
        subtitle: context.tr('home.zone_events_subtitle'),
        color: AppColors.primaryTeal,
        route: RouteNames.events,
      ),
      (
        icon: Icons.emoji_events_rounded,
        title: context.tr('home.zone_contest_title'),
        subtitle: context.tr('home.zone_contest_subtitle'),
        color: AppColors.accentSoftGold,
        route: RouteNames.contest,
      ),
      (
        icon: Icons.nightlife_rounded,
        title: context.tr('home.zone_an_thuong_title'),
        subtitle: context.tr('home.zone_an_thuong_subtitle'),
        color: const Color(0xFF8D7BC8),
        route: RouteNames.anThuong,
      ),
      (
        icon: Icons.waves_rounded,
        title: context.tr('home.zone_beach_title'),
        subtitle: context.tr('home.zone_beach_subtitle'),
        color: AppColors.primaryPastel,
        route: RouteNames.beach,
      ),
      (
        icon: Icons.flight_land_rounded,
        title: context.tr('home.zone_airport_title'),
        subtitle: context.tr('home.zone_airport_subtitle'),
        color: AppColors.warning,
        route: RouteNames.airportWelcome,
      ),
      (
        icon: Icons.threesixty_rounded,
        title: context.tr('home.zone_vr360_title'),
        subtitle: context.tr('home.zone_vr360_subtitle'),
        color: AppColors.success,
        route: RouteNames.vr360('dong_huyen_khong'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 76,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          return AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            onTap: () => context.push(item.route),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Dải ngang "Xem gần đây" (FE-02) – hoạt động cả khi ngoại tuyến, ẩn khi rỗng.
class _RecentlyViewedSection extends StatelessWidget {
  const _RecentlyViewedSection();

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: AppStrings.clearHistoryConfirmTitle,
      message: AppStrings.clearHistoryConfirmMessage,
      confirmLabel: AppStrings.clearHistoryAction,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<RecentlyViewedCubit>().clear();
    if (context.mounted) {
      showAppSnackBar(context, AppStrings.clearHistorySuccess, type: SnackType.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentIds = context.watch<RecentlyViewedCubit>().state;
    if (recentIds.isEmpty) return const SizedBox.shrink();

    final items = context.select((DestinationListCubit c) => c.state.items);
    if (items.isEmpty) return const SizedBox.shrink();

    final byId = {for (final d in items) d.id: d};
    // Giữ đúng thứ tự mới nhất lên đầu; bỏ qua êm những id đã bị xóa/không còn trong dữ liệu.
    final recentDestinations = <Destination>[
      for (final id in recentIds)
        if (byId[id] != null) byId[id]!,
    ];

    if (recentDestinations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionHeader(
          title: AppStrings.recentlyViewedTitle,
          subtitle: AppStrings.recentlyViewedSubtitle,
          actionLabel: AppStrings.clearHistoryAction,
          onAction: () => _confirmClearHistory(context),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            itemCount: recentDestinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => DestinationFeatureCard(
              destination: recentDestinations[i],
              width: 240,
            ),
          ),
        ),
      ],
    );
  }
}

/// Đặt riêng để các màn hình khác (danh sách) có thể tái sử dụng tiêu đề danh mục.
String categoryTitle(DestinationCategory? category) =>
    category?.label ?? AppLocalizations.trStatic('destinations.all_destinations');
