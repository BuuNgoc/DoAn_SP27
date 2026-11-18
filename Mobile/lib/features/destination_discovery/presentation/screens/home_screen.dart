import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/floating_ai_chat_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';

/// [Ảnh Mẫu 2: Pixel-Perfect] Trang chủ SmartTravel – Ngũ Hành Sơn.
/// Tái tạo chính xác 100% phong cách Shangri-La Circle Luxury:
/// 1. Top Section:
///    - Dãy núi thủy mặc & đường đồng mức mạ vàng mờ ảo phía sau
///    - Search Capsule trắng bo tròn chứa Golden Logo, Text "Ngũ Hành Sơn" & User Avatar
///    - 5 nút danh mục tròn (Di tích, Ẩm thực, Làng đá, Mua sắm, Sự kiện)
///    - Thanh Membership Loyalty Points màu vàng cát vân đồng mức (Tên thành viên + Điểm thưởng)
/// 2. Thân trang (White Sheet):
///    - Banner Carousel "Questers Rewards" với Mascot & CTA đỏ đất "Tham gia ngay"
///    - Bento Grid 3 thẻ (1 thẻ dọc bên trái, 2 thẻ ngang xếp chồng bên phải)
///    - Thanh Tabs Khám phá ("Khám phá", "Thủy Sơn", "Non Nước", "Sơn Thủy", "An Thượng") kèm vạch vàng kim
///    - Danh sách thẻ điểm đến sang trọng theo từng tab
///    - Nút nổi "Trợ lý AI" (Shangri-La Chat)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DestinationListCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _activeTabIndex = 0;
  static const List<String> _discoverTabs = [
    'Khám phá',
    'Thủy Sơn',
    'Non Nước',
    'Sơn Thủy',
    'An Thượng',
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.state.user);
    final userName = user != null && user.fullName.isNotEmpty ? user.fullName : 'Nguyễn Ngọc Bữu';
    final userPoints = user != null && user.loyaltyPoints > 0 ? user.loyaltyPoints : 280;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Warm Parchment
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<DestinationListCubit>().load(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── 1. Top Header with Mountain & Golden Contours Background ──
                SliverToBoxAdapter(
                  child: _ShangriLaTopHeader(
                    userName: userName,
                    userPoints: userPoints,
                    userAvatar: user?.avatarUrl,
                  ),
                ),

                // ── 2. Questers Rewards Carousel Banner ───────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: _QuestersRewardBanner(),
                  ),
                ),

                // ── 3. Bento Grid Section (1 Portrait Left + 2 Stacked Right) ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _ShangriLaBentoGrid(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── 4. Discover Tabs (Khám phá, Thủy Sơn, Non Nước...) ─────────
                SliverToBoxAdapter(
                  child: _ShangriLaDiscoverTabs(
                    tabs: _discoverTabs,
                    selectedIndex: _activeTabIndex,
                    onTabSelected: (index) {
                      setState(() => _activeTabIndex = index);
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── 5. Destination Horizontal Cards for Active Tab ───────────
                SliverToBoxAdapter(
                  child: _DiscoverDestinationsList(activeTabIndex: _activeTabIndex),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
              ],
            ),
          ),

          // ── 6. Floating AI Assistant Chat Button ────────────────────────────
          Positioned(
            left: 20,
            bottom: 24,
            child: FloatingAiChatButton(
              label: 'Trợ lý AI',
              onTap: () => context.push(RouteNames.aiChat),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. TOP HEADER PHONG CÁCH SHANGRI-LA (SEARCH CAPSULE, 5 ICONS, LOYALTY BAR)
// ─────────────────────────────────────────────────────────────────────────────

class _ShangriLaTopHeader extends StatelessWidget {
  const _ShangriLaTopHeader({
    required this.userName,
    required this.userPoints,
    this.userAvatar,
  });

  final String userName;
  final int userPoints;
  final String? userAvatar;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
      ),
      child: Stack(
        children: [
          // Lớp nền núi thủy mặc và đường đồng mức tinh tế
          Positioned.fill(
            child: CustomPaint(
              painter: _HeaderMountainPainter(),
            ),
          ),

          // Nội dung chính của Header
          Padding(
            padding: EdgeInsets.only(top: topPadding + 10, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1.1 Search Capsule Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE8E5DD), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F2B24).withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('${RouteNames.destinations}?focus=1'),
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              // Circular Golden Sun & Mountain Peak Emblem
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                                ),
                                child: Center(
                                  child: CustomPaint(
                                    size: const Size(14, 10),
                                    painter: _MiniPeakLogoPainter(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Location text (matches "Singapore" in mockup)
                              const Expanded(
                                child: Text(
                                  'Ngũ Hành Sơn, Đà Nẵng',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4A4D48),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              // User Avatar Icon
                              GestureDetector(
                                onTap: () => context.push(RouteNames.profile),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFD8D4CA), width: 1.0),
                                  ),
                                  child: ClipOval(
                                    child: userAvatar != null && userAvatar!.isNotEmpty
                                        ? Image.network(userAvatar!, fit: BoxFit.cover)
                                        : const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF242824)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── 1.2 Five Circular Quick Action Buttons ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickActionCircle(
                        icon: Icons.apartment_rounded,
                        label: 'Di tích',
                        onTap: () => context.push('${RouteNames.destinations}?cat=mountain_cave'),
                      ),
                      _QuickActionCircle(
                        icon: Icons.restaurant_rounded,
                        label: 'Ẩm thực',
                        onTap: () => context.push(RouteNames.anThuong),
                      ),
                      _QuickActionCircle(
                        icon: Icons.groups_rounded,
                        label: 'Làng đá',
                        onTap: () => context.push('${RouteNames.events}?kind=workshop'),
                      ),
                      _QuickActionCircle(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Mua sắm',
                        onTap: () => context.push(RouteNames.anThuong),
                      ),
                      _QuickActionCircle(
                        icon: Icons.celebration_rounded,
                        label: 'Sự kiện',
                        onTap: () => context.push(RouteNames.events),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── 1.3 Loyalty Points Strip (Sand Beige Contour Bar) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8DFD0), Color(0xFFDDD2C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD4C8B2), width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF242824).withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(RouteNames.rewards),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF242824),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$userPoints Điểm',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF242824),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF5A5D55)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _QuickActionCircle extends StatelessWidget {
  const _QuickActionCircle({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEBE7DD), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F2B24).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 23, color: const Color(0xFF242824)),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4D48),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. BANNER CAROUSEL "QUESTERS REWARDS" (MASCOT, TERRACOTTA RED CTA)
// ─────────────────────────────────────────────────────────────────────────────

class _QuestersRewardBanner extends StatelessWidget {
  const _QuestersRewardBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 146,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5F0EC), Color(0xFFF2F8F5), Color(0xFFFAF7F2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD3E4DC), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B24).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  // Mascot Illustration (Character with red Q)
                  Container(
                    width: 86,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCDE0D7), width: 0.8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB83A2E), // Terracotta Red
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.explore_rounded, color: Colors.white, size: 26),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Questers',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB83A2E),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Text content & CTA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Questers Rewards',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB83A2E), // Terracotta Red headline
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Stay, play, learn and earn perks every time you book as a family',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF4A4D48),
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Join Now Button (Solid Red Pill)
                        Material(
                          color: const Color(0xFFB83A2E),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => context.push(RouteNames.rewards),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Text(
                                'Tham gia ngay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dots indicator at bottom center
            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB83A2E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 4,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB69A67).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 4,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB69A67).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
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

// ─────────────────────────────────────────────────────────────────────────────
// 3. BENTO GRID (1 PORTRAIT LEFT + 2 STACKED LANDSCAPE RIGHT)
// ─────────────────────────────────────────────────────────────────────────────

class _ShangriLaBentoGrid extends StatelessWidget {
  const _ShangriLaBentoGrid();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Row(
        children: [
          // ── Left Portrait Card: Shangri-La Boutique ──
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: () => context.push('${RouteNames.events}?kind=workshop'),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const CoverImage(
                        source: 'assets/images/artisan_workshop.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SMART TRAVEL\nBOUTIQUE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEB001B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(-6, 0),
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Text(
                              'Khám phá & Nhận ưu đãi 50.000đ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Right Column: 2 Stacked Landscape Cards ──
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // Right Top Card: Member Exclusive (Sunset Beach)
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(RouteNames.rewards),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const CoverImage(
                              source: 'assets/images/son_thuy_beach.jpg',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // "Member Exclusive" Pill Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Member Exclusive',
                                      style: TextStyle(
                                        color: Color(0xFF242824),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Tích lũy điểm thưởng khi check-in Ngũ Hành Sơn',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Right Bottom Card: Cultural Heritage Tapestry
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(RouteNames.destinations),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const CoverImage(
                              source: 'assets/images/linh_ung_pagoda.jpg',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Chạm vào chiều sâu văn hóa tâm linh miền di sản...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// 4. DISCOVER CATEGORY TABS (KHÁM PHÁ, THỦY SƠN, NON NƯỚC...)
// ─────────────────────────────────────────────────────────────────────────────

class _ShangriLaDiscoverTabs extends StatelessWidget {
  const _ShangriLaDiscoverTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 24),
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTabSelected(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tabs[i],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF242824) : const Color(0xFF8C8E8A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                // Golden underline indicator for active tab
                Container(
                  width: isSelected ? 36 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFB69A67) : Colors.transparent, // Soft Gold
                    borderRadius: BorderRadius.circular(2),
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

// ─────────────────────────────────────────────────────────────────────────────
// 5. HORIZONTAL DESTINATION CARDS FOR ACTIVE TAB
// ─────────────────────────────────────────────────────────────────────────────

class _DiscoverDestinationsList extends StatelessWidget {
  const _DiscoverDestinationsList({required this.activeTabIndex});

  final int activeTabIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationListCubit, DestinationListState>(
      builder: (context, state) {
        if (state.status.isLoading) {
          return const SizedBox(
            height: 240,
            child: LoadingState(message: 'Đang tải danh thắng Ngũ Hành Sơn...'),
          );
        }

        if (state.status.isFailure) {
          return SizedBox(
            height: 240,
            child: ErrorState(
              message: state.errorMessage ?? 'Không thể tải danh sách',
              onRetry: () => context.read<DestinationListCubit>().load(),
            ),
          );
        }

        // Lọc danh sách điểm đến theo tab đang chọn
        List<Destination> filtered = state.items;
        if (activeTabIndex == 1) {
          // Thủy Sơn
          filtered = state.items.where((d) => d.name.contains('Thủy Sơn') || d.name.contains('Huyền Không') || d.name.contains('Tam Thai')).toList();
        } else if (activeTabIndex == 2) {
          // Non Nước
          filtered = state.items.where((d) => d.name.contains('Non Nước') || d.name.contains('Làng') || d.name.contains('Linh Ứng')).toList();
        } else if (activeTabIndex == 3) {
          // Sơn Thủy
          filtered = state.items.where((d) => d.name.contains('Biển') || d.name.contains('Sơn Thủy') || d.category == DestinationCategory.beach).toList();
        } else if (activeTabIndex == 4) {
          // An Thượng
          filtered = state.items.where((d) => d.name.contains('An Thượng') || d.category == DestinationCategory.anThuong).toList();
        }

        if (filtered.isEmpty) {
          filtered = state.items;
        }

        return SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final d = filtered[i];
              return _ShangriLaDestinationCard(destination: d);
            },
          ),
        );
      },
    );
  }
}

class _ShangriLaDestinationCard extends StatelessWidget {
  const _ShangriLaDestinationCard({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.destinationDetail(destination.id)),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBE7DE), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F2B24).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CoverImage(
                  source: destination.coverImage,
                  fit: BoxFit.cover,
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF242824),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF8C8E8A)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.address,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8C8E8A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 15, color: Color(0xFFB69A67)),
                            const SizedBox(width: 3),
                            Text(
                              destination.ratingAvg.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF242824),
                              ),
                            ),
                          ],
                        ),
                        // Price tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3ECE1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            destination.ticketInfo.contains('Miễn phí') ? 'Miễn phí' : 'Từ 40.000đ',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8F6D38),
                            ),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS (DÃY NÚI THỦY MẶC & ĐƯỜNG ĐỒNG MỨC MỜ ẢO CHO HEADER)
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderMountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Lớp nếp đồng mức vàng kim phía trên
    final contourPaint = Paint()
      ..color = const Color(0xFFD4B886).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..isAntiAlias = true;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final baseY = 20.0 + i * 16.0;
      path.moveTo(-10, baseY);
      path.cubicTo(
        size.width * 0.3, baseY + 18 * math.sin(i * 0.5),
        size.width * 0.7, baseY - 20 * math.cos(i * 0.4),
        size.width + 10, baseY + 8,
      );
      canvas.drawPath(path, contourPaint);
    }

    // Tầng núi xa xanh rêu nhạt (Light Moss Sage)
    final mountainPaint1 = Paint()
      ..color = const Color(0xFFCCD6C8).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.35, size.width * 0.65, size.height * 0.70)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.45, size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, mountainPaint1);

    // Tầng núi gần xanh ngọc (Sage Green)
    final mountainPaint2 = Paint()
      ..color = const Color(0xFFA8BCA3).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(-10, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.60, size.width * 0.50, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width + 10, size.height * 0.90)
      ..lineTo(size.width + 10, size.height)
      ..lineTo(-10, size.height)
      ..close();
    canvas.drawPath(path2, mountainPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniPeakLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Đỉnh trên
    final pathTop = Path();
    pathTop.moveTo(size.width * 0.2, size.height * 0.6);
    pathTop.quadraticBezierTo(size.width * 0.5, size.height * 0.1, size.width * 0.8, size.height * 0.6);
    canvas.drawPath(pathTop, strokePaint);

    // Đáy lượn sóng
    final pathBottom = Path();
    pathBottom.moveTo(size.width * 0.3, size.height * 0.8);
    pathBottom.quadraticBezierTo(size.width * 0.5, size.height * 0.45, size.width * 0.7, size.height * 0.8);
    canvas.drawPath(pathBottom, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
