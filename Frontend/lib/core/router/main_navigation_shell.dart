import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/offline_banner_widget.dart';
import '../constants/app_colors.dart';
import '../localization/app_localizations.dart';
import '../network/connectivity_cubit.dart';

/// Khung điều hướng chính: thanh NavigationBar nổi bo tròn với 5 tab
/// + dải thông báo ngoại tuyến tự động (LI-01, LI-05, LI-06).
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  List<NavigationDestination> _buildDestinations(BuildContext context) => [
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore_rounded),
          label: context.tr('nav.explore'),
          tooltip: context.tr('nav.explore_tooltip'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.map_outlined),
          selectedIcon: const Icon(Icons.map_rounded),
          label: context.tr('nav.map'),
          tooltip: context.tr('nav.map_tooltip'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.auto_awesome_outlined),
          selectedIcon: const Icon(Icons.auto_awesome_rounded),
          label: context.tr('nav.ai_itinerary'),
          tooltip: context.tr('nav.ai_tooltip'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.qr_code_scanner_outlined),
          selectedIcon: const Icon(Icons.qr_code_scanner_rounded),
          label: context.tr('nav.checkin_rewards'),
          tooltip: context.tr('nav.checkin_tooltip'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: context.tr('nav.personal'),
          tooltip: context.tr('nav.personal_tooltip'),
        ),
      ];

  void _onSelect(int index) => navigationShell.goBranch(
        index,
        // Bấm lại tab đang mở → quay về màn hình gốc của tab.
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundIceMint,
      body: BlocBuilder<ConnectivityCubit, bool>(
        builder: (context, isOnline) => Column(
          children: [
            const OfflineBannerWidget(),
            Expanded(
              // Khi dải ngoại tuyến hiện, nó đã chiếm vùng status bar.
              child: MediaQuery.removePadding(context: context, removeTop: !isOnline, child: navigationShell),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset > 0 ? bottomInset : 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: NavigationBar(
                height: 68,
                backgroundColor: AppColors.surfaceWhite.withValues(alpha: 0.96),
                indicatorColor: AppColors.primaryTeal.withValues(alpha: 0.14),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onSelect,
                destinations: _buildDestinations(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
