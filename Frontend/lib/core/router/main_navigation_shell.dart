import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/offline_banner_widget.dart';
import '../../shared/widgets/tourism_bottom_navigation.dart';
import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';
import '../network/connectivity_cubit.dart';

/// Khung điều hướng di động chính (360Mobile App):
/// - Trải nghiệm thuần Mobile App 100% với 5 tab khám phá.
/// - Trên màn hình máy tính / Web: Căn giữa khung hình điện thoại (max-width: 500px)
///   tạo trải nghiệm ứng dụng di động chân thực nhất.
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  List<TourismNavItem> _buildNavItems(BuildContext context) => [
        TourismNavItem(
          icon: Icons.explore_outlined,
          selectedIcon: Icons.explore_rounded,
          label: context.tr('nav.explore'),
        ),
        TourismNavItem(
          icon: Icons.map_outlined,
          selectedIcon: Icons.map_rounded,
          label: context.tr('nav.map'),
        ),
        TourismNavItem(
          icon: Icons.auto_awesome_outlined,
          selectedIcon: Icons.auto_awesome_rounded,
          label: context.tr('nav.ai_itinerary'),
        ),
        TourismNavItem(
          icon: Icons.qr_code_scanner_outlined,
          selectedIcon: Icons.qr_code_scanner_rounded,
          label: context.tr('nav.checkin_rewards'),
        ),
        TourismNavItem(
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          label: context.tr('nav.personal'),
        ),
      ];

  void _onSelect(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final navItems = _buildNavItems(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 background
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BlocBuilder<ConnectivityCubit, bool>(
            builder: (context, isOnline) => Column(
              children: [
                const OfflineBannerWidget(),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: !isOnline,
                    child: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: TourismBottomNavigation(
            currentIndex: navigationShell.currentIndex,
            onTap: _onSelect,
            items: navItems,
          ),
        ),
      ),
    );
  }
}
