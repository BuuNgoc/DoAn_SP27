import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/offline_banner_widget.dart';
import '../constants/app_colors.dart';
import '../network/connectivity_cubit.dart';

/// Khung điều hướng chính: thanh NavigationBar nổi bo tròn với 5 tab
/// + dải thông báo ngoại tuyến tự động (LI-01, LI-05).
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: 'Khám phá',
      tooltip: 'Khám phá điểm đến, sự kiện, phân khu',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map_rounded),
      label: 'Bản đồ',
      tooltip: 'Bản đồ tương tác Ngũ Hành Sơn',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'AI & Lịch trình',
      tooltip: 'Nhận diện ảnh và lịch trình AI',
    ),
    NavigationDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner_rounded),
      label: 'Check-in & Quà',
      tooltip: 'Check-in QR, điểm thưởng, đổi quà',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Cá nhân',
      tooltip: 'Hồ sơ, đặt chỗ, đánh giá',
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
                destinations: _destinations,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
