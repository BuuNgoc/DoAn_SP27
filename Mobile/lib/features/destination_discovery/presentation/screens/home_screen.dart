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
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/tourism_components.dart';
import '../../../../shared/widgets/tourism_search_bar.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';

/// [Redesign Shangri-La Circle] Trang chủ Du lịch Thông minh Smart Travel Ngũ Hành Sơn.
/// Phong cách thiết kế:
/// - Luxury hospitality & Minimalist premium interface
/// - Large immersive photography hero
/// - Editorial-style sections (Trải nghiệm bản sắc địa phương, Nghỉ dưỡng & Khách sạn, VR360, AI Assistant)
/// - Spacious white space, refined card components
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
          // ── 1. Luxury Hospitality Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _LuxuryHomeHeader(greetingName: greetingName, userAvatar: user?.avatarUrl),
          ),

          // ── 2. Large Immersive Hero Section ───────────────────────────────────
          const SliverToBoxAdapter(
            child: _ShangriLaHeroSection(),
          ),

          // ── 3. Minimalist Search Bar ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: TourismSearchBar(
                readOnly: true,
                hintText: 'Bạn muốn khám phá điều gì?',
                onTap: () => context.push('${RouteNames.destinations}?focus=1'),
                onFilterTap: () => context.push(RouteNames.destinations),
              ),
            ),
          ),

          // ── 4. Elegant Category Pills ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ShangriLaCategoryBar(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── 5. Featured Destinations (Điểm đến nổi bật) ──────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Điểm Đến Nổi Bật',
              subtitle: 'Những danh lam thắng cảnh huyền bí không thể bỏ lỡ',
              actionLabel: 'Xem tất cả',
              icon: Icons.auto_awesome_rounded,
              onAction: () => context.push(RouteNames.destinations),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: BlocBuilder<DestinationListCubit, DestinationListState>(
              builder: (context, state) {
                if (state.status.isLoading) {
                  return const SizedBox(height: 280, child: LoadingState(message: 'Đang tải danh thắng...'));
                }
                if (state.status.isFailure) {
                  return SizedBox(
                    height: 280,
                    child: ErrorState(
                      message: state.errorMessage ?? 'Không thể tải danh sách',
                      onRetry: () => context.read<DestinationListCubit>().load(),
                    ),
                  );
                }
                final featured = [...state.items]..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
                return SizedBox(
                  height: 285,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: featured.take(6).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final item = featured[i];
                      return DestinationCard(
                        width: 260,
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

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── 6. Local Experiences (Trải nghiệm bản sắc địa phương) ─────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Trải Nghiệm Bản Sắc Địa Phương',
              subtitle: 'Nghề thủ công 400 năm, làng đá Non Nước & văn hóa miền Trung',
              actionLabel: 'Xem tất cả',
              icon: Icons.palette_outlined,
              onAction: () => context.push('${RouteNames.events}?kind=workshop'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 320,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ExperienceCard(
                    title: 'Workshop Tự Tay Chạm Khắc Tượng Đá Non Nước',
                    imageUrl: 'assets/images/artisan_workshop.jpg',
                    location: 'Làng Đá Mỹ Nghệ Non Nước',
                    duration: '90 phút',
                    price: '350.000đ',
                    category: 'LÀNG NGHỀ TRUYỀN THỐNG',
                    rating: 4.9,
                    reviewCount: 148,
                    onTap: () => context.push(RouteNames.events),
                  ),
                  const SizedBox(width: 16),
                  ExperienceCard(
                    title: 'Trải Nghiệm Làm Đèn Lồng Cổ Truyền Hội An & Đà Nẵng',
                    imageUrl: 'assets/images/linh_ung_pagoda.jpg',
                    location: 'Không gian Văn hóa Phố Cổ Non Nước',
                    duration: '60 phút',
                    price: '280.000đ',
                    category: 'THỦ CÔNG MỸ NGHỆ',
                    rating: 4.8,
                    reviewCount: 96,
                    onTap: () => context.push(RouteNames.events),
                  ),
                  const SizedBox(width: 16),
                  ExperienceCard(
                    title: 'Food Tour: Ẩm Thực Miền Trung Quanh Chân Rặng Ngũ Hành',
                    imageUrl: 'assets/images/an_thuong_street.jpg',
                    location: 'Khu ẩm thực & Phố đêm Non Nước',
                    duration: '120 phút',
                    price: '420.000đ',
                    category: 'ẨM THỰC ĐẶC SẢN',
                    rating: 5.0,
                    reviewCount: 210,
                    onTap: () => context.push(RouteNames.anThuong),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── 7. Hotels & Accommodation (Nghỉ dưỡng & Khách sạn) ────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Nghỉ Dưỡng & Khách Sạn',
              subtitle: 'Không gian lưu trú sang trọng hướng biển và rặng núi đá',
              actionLabel: 'Xem thêm',
              icon: Icons.hotel_outlined,
              onAction: () => context.push(RouteNames.beach),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  HotelCard(
                    name: 'Shangri-La Da Nang Non Nuoc Resort & Spa',
                    imageUrl: 'assets/images/son_thuy_beach.jpg',
                    location: 'Bãi biển Non Nước, Ngũ Hành Sơn',
                    pricePerNight: '4.850.000đ',
                    stars: 5,
                    rating: 4.9,
                    reviewCount: 312,
                    onTap: () => context.push(RouteNames.beach),
                  ),
                  const SizedBox(width: 16),
                  HotelCard(
                    name: 'Sandy Beach Luxury Heritage Villas',
                    imageUrl: 'assets/images/marble_mountains.jpg',
                    location: 'Đường Trường Sa, Ngũ Hành Sơn',
                    pricePerNight: '3.200.000đ',
                    stars: 5,
                    rating: 4.8,
                    reviewCount: 185,
                    onTap: () => context.push(RouteNames.beach),
                  ),
                  const SizedBox(width: 16),
                  HotelCard(
                    name: 'Boutique Marble Mountain Retreat',
                    imageUrl: 'assets/images/linh_ung_panorama.jpg',
                    location: 'Chân núi Thủy Sơn, Ngũ Hành Sơn',
                    pricePerNight: '1.950.000đ',
                    stars: 4,
                    rating: 4.7,
                    reviewCount: 92,
                    onTap: () => context.push(RouteNames.beach),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── 8. VR360 Experience (Explore before you arrive) ───────────────────
          const SliverToBoxAdapter(
            child: _Vr360ShangriLaSection(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── 9. AI Travel Assistant (Your Personal Travel Assistant) ───────────
          const SliverToBoxAdapter(
            child: _AiPersonalAssistantSection(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── 10. Curated for You & Specialized Zones (Gợi ý dành cho bạn) ─────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Gợi Ý Dành Cho Bạn',
              subtitle: 'Các phân khu trải nghiệm đặc sắc tại Ngũ Hành Sơn',
              icon: Icons.explore_outlined,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          const SliverToBoxAdapter(child: _ExperienceZonesGrid()),

          // ── 11. Recently Viewed Section ──────────────────────────────────────
          const SliverToBoxAdapter(child: _RecentlyViewedSection()),

          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.bottomNavClearance)),
        ],
      ),
    );
  }
}

/// Header Luxury phong cách Shangri-La Hospitality
class _LuxuryHomeHeader extends StatelessWidget {
  const _LuxuryHomeHeader({required this.greetingName, this.userAvatar});

  final String greetingName;
  final String? userAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand Logo & Greeting
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
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.diamond_outlined, size: 11, color: AppColors.accent),
                            SizedBox(width: 4),
                            Text(
                              'SMART TRAVEL NGŨ HÀNH SƠN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
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
                    'Xin chào, $greetingName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            // Actions: Notifications & Avatar
            Row(
              children: [
                _CircleLuxuryButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Thông báo',
                  onTap: () {
                    showAppSnackBar(context, 'Chưa có thông báo mới.', type: SnackType.info);
                  },
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.push(RouteNames.profile),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.softGold, width: 1.5),
                    ),
                    child: ClipOval(
                      child: userAvatar != null && userAvatar!.isNotEmpty
                          ? Image.network(userAvatar!, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.primarySurface,
                              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleLuxuryButton extends StatelessWidget {
  const _CircleLuxuryButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Hero Section phong cách Shangri-La: Large Immersive Photography
class _ShangriLaHeroSection extends StatelessWidget {
  const _ShangriLaHeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Large landscape photography of Marble Mountains
            const CoverImage(
              source: 'assets/images/marble_mountains.jpg',
              fit: BoxFit.cover,
            ),
            // Luxury Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroOverlayGradient,
              ),
            ),
            // Text Overlay & CTA
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softGold,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: const Text(
                      'DI SẢN THIÊN NHIÊN & TÂM LINH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Discover the beauty of\nNgũ Hành Sơn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Một hành trình, ngàn trải nghiệm',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => context.push(RouteNames.destinations),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.warmIvory,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text(
                      'Khám phá ngay',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.3),
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

/// Category Bar phong cách Shangri-La Minimalist Pills
class _ShangriLaCategoryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = DestinationCategory.values;
    return SizedBox(
      height: 42,
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

/// Section 8: VR360 Experience ("Explore before you arrive")
class _Vr360ShangriLaSection extends StatelessWidget {
  const _Vr360ShangriLaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CoverImage(
              source: 'assets/images/huyen_khong_panorama.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                    AppColors.primary.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softGold,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: const Text(
                      'EXPLORE BEFORE YOU ARRIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Khám phá Ngũ Hành Sơn qua VR360',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trải nghiệm không gian và cảnh quan trước khi bạn đặt chân đến.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => context.push(RouteNames.vr360('dong_huyen_khong')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.warmIvory,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                      ),
                    ),
                    icon: const Icon(Icons.threesixty_rounded, size: 16),
                    label: const Text(
                      'Trải nghiệm ngay',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
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

/// Section 9: AI Travel Assistant ("Your Personal Travel Assistant")
class _AiPersonalAssistantSection extends StatelessWidget {
  const _AiPersonalAssistantSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TourismCard(
        padding: const EdgeInsets.all(AppDimensions.s20),
        backgroundColor: AppColors.surface,
        borderColor: AppColors.border,
        radius: AppDimensions.radius20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.softGold, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Personal Travel Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Để chúng tôi giúp bạn khám phá hành trình hoàn hảo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'GỢI Ý CÂU HỎI NHANH',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AssistantQuestionChip(
                  label: 'Lịch trình 1 ngày tham quan 5 ngọn núi?',
                  onTap: () => context.push(RouteNames.aiChat, extra: 'Lịch trình 1 ngày tham quan 5 ngọn núi?'),
                ),
                _AssistantQuestionChip(
                  label: 'Nên ghé Động Huyền Không lúc mấy giờ?',
                  onTap: () => context.push(RouteNames.aiChat, extra: 'Nên ghé Động Huyền Không lúc mấy giờ để thấy giếng trời đẹp nhất?'),
                ),
                _AssistantQuestionChip(
                  label: 'Đặc sản ẩm thực ngon quanh làng đá Non Nước?',
                  onTap: () => context.push(RouteNames.aiChat, extra: 'Đặc sản ẩm thực ngon quanh làng đá Non Nước?'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => context.push(RouteNames.aiPlanner),
                  icon: const Icon(Icons.tune_rounded, size: 15, color: AppColors.primary),
                  label: const Text(
                    'AI Smart Planner',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(RouteNames.aiChat),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                  label: const Text(
                    'Trò chuyện ngay',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantQuestionChip extends StatelessWidget {
  const _AssistantQuestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundSubtle,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 13, color: AppColors.softGold),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
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
        color: AppColors.secondaryDark,
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
        const SizedBox(height: 28),
        SectionHeader(
          title: AppStrings.recentlyViewedTitle,
          subtitle: AppStrings.recentlyViewedSubtitle,
          actionLabel: AppStrings.clearHistoryAction,
          icon: Icons.history_rounded,
          onAction: () => _confirmClearHistory(context),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 285,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recentDestinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final d = recentDestinations[i];
              return DestinationCard(
                width: 250,
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
