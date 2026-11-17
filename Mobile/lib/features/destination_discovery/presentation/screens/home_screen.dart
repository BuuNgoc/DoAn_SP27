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
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/category_chip.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/tourism_components.dart';
import '../../../../shared/widgets/tourism_search_bar.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';
import '../widgets/destination_widgets.dart';

/// [FE-02] Trang chủ Du lịch Thông minh NHS360 – Ngũ Hành Sơn.
/// Thiết kế chuẩn UI/UX Pro Max Tourism Design System:
/// Hero Visual Storytelling, Fast Search, Category Pills, VR360 Experience,
/// Events & Non Nuoc Stone Workshops, Check-in Passport & Local Zones.
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
      color: AppColors.primary,
      onRefresh: () => context.read<DestinationListCubit>().load(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── 1. Hero & Welcome Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HomeHeroHeader(greetingName: greetingName),
          ),

          // ── 2. Interactive Search Bar ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: TourismSearchBar(
                readOnly: true,
                onTap: () => context.push('${RouteNames.destinations}?focus=1'),
                onFilterTap: () => context.push(RouteNames.destinations),
              ),
            ),
          ),

          // ── 3. Quick Categories Pills ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _HomeCategoryBar(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── 4. VR360 Immersive Experience Showcase ──────────────────────────
          const SliverToBoxAdapter(child: _Vr360HeroShowcase()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── 5. AI Travel Assistant Banner (RAG & Photo Vision) ──────────────
          const SliverToBoxAdapter(child: _AiTravelAssistantBanner()),

          // ── 6. Recently Viewed (Offline cache) ──────────────────────────────
          const SliverToBoxAdapter(child: _RecentlyViewedSection()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── 7. Featured Destinations Carousel ───────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: context.tr('home.featured_title'),
              subtitle: 'Danh lam thắng cảnh tiêu biểu tại 5 ngọn Ngũ Hành',
              actionLabel: context.tr('common.view_all'),
              icon: Icons.auto_awesome_rounded,
              onAction: () => context.push(RouteNames.destinations),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: BlocBuilder<DestinationListCubit, DestinationListState>(
              builder: (context, state) {
                if (state.status.isLoading) {
                  return const SizedBox(height: 270, child: LoadingState(message: 'Đang tải danh thắng...'));
                }
                if (state.status.isFailure) {
                  return SizedBox(
                    height: 270,
                    child: ErrorState(
                      message: state.errorMessage ?? 'Không thể tải danh sách',
                      onRetry: () => context.read<DestinationListCubit>().load(),
                    ),
                  );
                }
                final featured = [...state.items]..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
                return SizedBox(
                  height: 270,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: featured.take(6).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, i) {
                      final item = featured[i];
                      return DestinationCard(
                        width: 250,
                        title: item.name,
                        imageUrl: item.coverImage,
                        category: item.category.label,
                        rating: item.ratingAvg,
                        reviewCount: item.reviewCount,
                        location: item.address,
                        hasVr360: item.hasVr360,
                        hasAudioGuide: item.hasAudioGuide,
                        onTap: () => context.push(RouteNames.destinationDetail(item.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── 8. QR Check-in Passport & Rewards Gamification ──────────────────
          const SliverToBoxAdapter(child: _CheckInPassportBanner()),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── 9. Non Nuoc Stone Village & Cultural Workshops ─────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Làng Đá Non Nước & Trải Nghiệm',
              subtitle: 'Giao lưu nghệ nhân và tự tay chạm khắc đá lưu niệm',
              actionLabel: 'Xem tất cả',
              icon: Icons.handyman_rounded,
              onAction: () => context.push('${RouteNames.events}?kind=workshop'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(
                    width: 280,
                    child: WorkshopCard(
                      title: 'Workshop Chạm khắc Tượng Chibi Đá',
                      artisanName: 'Lê Triều',
                      imageUrl: 'assets/images/artisan_workshop.jpg',
                      durationText: '90 phút',
                      onTap: () => context.push(RouteNames.events),
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 280,
                    child: WorkshopCard(
                      title: 'Kỹ thuật Mài Ngọc Bích & Vân Đá Cẩm Thạch',
                      artisanName: 'Nguyễn Văn Hùng',
                      imageUrl: 'assets/images/huyen_khong_cave.jpg',
                      durationText: '120 phút',
                      onTap: () => context.push(RouteNames.events),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── 10. Local Specialized Tourism Zones ─────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: context.tr('home.zones_title'),
              subtitle: context.tr('home.zones_subtitle'),
              icon: Icons.explore_rounded,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: _ExperienceZonesGrid()),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── 11. Immersive Audio & VR Guides List ───────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: context.tr('home.immersive_title'),
              subtitle: 'Thuyết minh đa ngữ vi/en/ko/zh & không gian 360',
              actionLabel: context.tr('common.see_more'),
              icon: Icons.headphones_rounded,
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

/// Header chào mừng phong cách Storytelling Du lịch
class _HomeHeroHeader extends StatelessWidget {
  const _HomeHeroHeader({required this.greetingName});

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Đà Nẵng • Ngũ Hành Sơn',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Xin chào, $greetingName 👋',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Khám phá danh thắng Ngũ Hành',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            // Favorite & Notification Actions
            Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.favorite_border_rounded,
                  tooltip: 'Danh sách yêu thích',
                  onTap: () => context.push(RouteNames.favorites),
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.qr_code_scanner_rounded,
                  tooltip: 'Quét Check-in',
                  isAccent: true,
                  onTap: () => context.push(RouteNames.qrScanner),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isAccent = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isAccent ? AppColors.accentSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isAccent ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border,
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 20,
              color: isAccent ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dải thanh danh mục vuốt ngang với CategoryChip
class _HomeCategoryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = DestinationCategory.values;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return CategoryChip(
              label: 'Tất cả điểm đến',
              icon: Icons.grid_view_rounded,
              isSelected: true,
              onTap: () => context.push(RouteNames.destinations),
            );
          }
          final cat = categories[i - 1];
          return CategoryChip(
            label: cat.label,
            icon: cat.icon,
            isSelected: false,
            onTap: () => context.push('${RouteNames.destinations}?category=${cat.code}'),
          );
        },
      ),
    );
  }
}

/// Banner VR360 sống động (FE-03)
class _Vr360HeroShowcase extends StatelessWidget {
  const _Vr360HeroShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TourismCard(
        padding: EdgeInsets.zero,
        gradient: AppColors.oceanGradient,
        onTap: () => context.push(RouteNames.vr360('dong_huyen_khong')),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.view_in_ar_rounded,
                size: 150,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.threesixty_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'TRẢI NGHIỆM THỰC TẾ ẢO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Khám phá Động Huyền Không 360°',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chiêm ngưỡng giếng trời ánh sáng và không gian hang động linh thiêng từ xa',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
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

/// Thẻ Trợ lý AI du lịch NHS360 (FE-05)
class _AiTravelAssistantBanner extends StatelessWidget {
  const _AiTravelAssistantBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TourismCard(
        padding: const EdgeInsets.all(18),
        backgroundColor: AppColors.surface,
        borderColor: AppColors.primaryLight.withValues(alpha: 0.5),
        onTap: () => context.push(RouteNames.aiPlanner),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.auroraGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.floatingShadow,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'AI Travel Assistant',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'GEMINI AI',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Nhận diện ảnh danh thắng & Tự động lên lịch trình cá nhân hóa',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Hộ chiếu du lịch & Tích điểm Check-in QR (FE-08, FE-09)
class _CheckInPassportBanner extends StatelessWidget {
  const _CheckInPassportBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TourismCard(
        padding: const EdgeInsets.all(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => context.push(RouteNames.checkin),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: const Text(
                      'HỘ CHIẾU CHECK-IN',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Quét QR tại 5 ngọn Ngũ Hành',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tích điểm thưởng đổi quà lưu niệm đá Non Nước & Voucher',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primaryLight,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lưới các khu trải nghiệm chuyên biệt (FE-12, FE-13, FE-14)
class _ExperienceZonesGrid extends StatelessWidget {
  const _ExperienceZonesGrid();

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String title, String subtitle, Color color, String route})>[
      (
        icon: Icons.nightlife_rounded,
        title: 'Phố Tây An Thượng',
        subtitle: 'Ẩm thực & Nightlife',
        color: const Color(0xFF8B5CF6),
        route: RouteNames.anThuong,
      ),
      (
        icon: Icons.waves_rounded,
        title: 'Biển Non Nước',
        subtitle: 'Sơn Thủy & Tân Trà',
        color: AppColors.primaryLight,
        route: RouteNames.beach,
      ),
      (
        icon: Icons.emoji_events_rounded,
        title: 'Thi Điêu Khắc Đá',
        subtitle: 'Bình chọn tác phẩm',
        color: AppColors.accent,
        route: RouteNames.contest,
      ),
      (
        icon: Icons.flight_land_rounded,
        title: 'Chào đón Sân Bay',
        subtitle: 'Ưu đãi du khách đến',
        color: AppColors.secondary,
        route: RouteNames.airportWelcome,
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
          mainAxisExtent: 80,
        ),
        itemBuilder: (context, i) {
          final item = items[i];
          return TourismCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => context.push(item.route),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
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
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
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

/// Dải ngang "Xem gần đây" (Offline persistence)
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
          icon: Icons.history_rounded,
          onAction: () => _confirmClearHistory(context),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recentDestinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final d = recentDestinations[i];
              return DestinationCard(
                width: 240,
                title: d.name,
                imageUrl: d.coverImage,
                category: d.category.label,
                rating: d.ratingAvg,
                reviewCount: d.reviewCount,
                location: d.address,
                hasVr360: d.hasVr360,
                hasAudioGuide: d.hasAudioGuide,
                onTap: () => context.push(RouteNames.destinationDetail(d.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tiêu đề danh mục điểm đến dùng chung
String categoryTitle(DestinationCategory? category) =>
    category?.label ?? AppLocalizations.trStatic('destinations.all_destinations');

