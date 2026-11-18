import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/tourism_components.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../destination_discovery/presentation/bloc/destination_cubits.dart';
import '../bloc/booking_cubits.dart';
import '../widgets/booking_widgets.dart';

/// [Redesign Shangri-La Circle] Màn hình Quản lý Hành trình & Chuyến đi (My Trip).
/// Giao diện tinh tế phong cách Luxury Hospitality:
/// - Upcoming trips & vé đặt chỗ
/// - Daily Itinerary Timeline (Sáng / Chiều / Hoàng hôn)
/// - Saved destinations (Yêu thích)
/// - Lối tắt Bản đồ & Kế hoạch AI
/// - Booking History (Lịch sử giao dịch)
class MyTripScreen extends StatelessWidget {
  const MyTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.state.user);
    final userId = user?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = sl<BookingHistoryCubit>();
            if (userId.isNotEmpty) cubit.load(userId);
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => sl<DestinationListCubit>()..load(),
        ),
      ],
      child: _MyTripView(userId: userId),
    );
  }
}

class _MyTripView extends StatefulWidget {
  const _MyTripView({required this.userId});

  final String userId;

  @override
  State<_MyTripView> createState() => _MyTripViewState();
}

class _MyTripViewState extends State<_MyTripView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            SliverToBoxAdapter(
              child: _buildQuickActionRow(context),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabHeaderDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Lịch trình & Đang diễn ra'),
                    Tab(text: 'Vé & Lịch sử đặt chỗ'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildItineraryTab(context),
              _buildBookingsTab(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HÀNH TRÌNH CỦA BẠN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.primaryLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.textSecondary),
                onPressed: () => context.push(RouteNames.aiPlanner),
                tooltip: 'Tạo lịch trình AI',
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Khám Phá Ngũ Hành Sơn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quản lý trải nghiệm, điểm đến đã lưu và các hoạt động trong ngày.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickCardButton(
              icon: Icons.map_rounded,
              title: 'Bản đồ số 360°',
              subtitle: 'Định vị điểm đến',
              onTap: () => context.push(RouteNames.map),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickCardButton(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Smart Planner',
              subtitle: 'Tối ưu lộ trình',
              iconColor: AppColors.softGold,
              onTap: () => context.push(RouteNames.aiPlanner),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, AppDimensions.bottomNavClearance),
      children: [
        // ── 1. Daily Itinerary Timeline ─────────────────────────────────────
        const Text(
          'LỘ TRÌNH GỢI Ý HÔM NAY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        const _TimelineEventItem(
          time: '08:30 - 10:30',
          period: 'BUỔI SÁNG',
          title: 'Chiêm bái Chùa Linh Ứng & Động Huyền Không',
          location: 'Ngọn Thủy Sơn, Ngũ Hành Sơn',
          badgeText: 'Di tích Quốc gia',
          isFirst: true,
        ),
        const _TimelineEventItem(
          time: '11:00 - 12:30',
          period: 'TRƯA',
          title: 'Thưởng thức Ẩm thực Mì Quảng & Đặc sản Non Nước',
          location: 'Khu ẩm thực truyền thống Ngũ Hành Sơn',
          badgeText: 'Ẩm thực địa phương',
        ),
        const _TimelineEventItem(
          time: '14:00 - 16:00',
          period: 'BUỔI CHIỀU',
          title: 'Workshop Tự tay Chạm khắc Đá Nghệ nhân',
          location: 'Làng đá mỹ nghệ Non Nước (400 năm)',
          badgeText: 'Di sản phi vật thể',
        ),
        const _TimelineEventItem(
          time: '17:00 - 18:30',
          period: 'HOÀNG HÔN',
          title: 'Ngắm hoàng hôn Vọng Giang Đài & Biển Non Nước',
          location: 'Đỉnh Thủy Sơn hướng nhìn sông Cổ Cò',
          badgeText: 'Trải nghiệm đỉnh cao',
          isLast: true,
        ),

        const SizedBox(height: 28),

        // ── 2. Saved Destinations Carousel ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ĐIỂM ĐẾN ĐÃ LƯU',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.primary,
              ),
            ),
            TextButton(
              onPressed: () => context.push(RouteNames.favorites),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BlocBuilder<DestinationListCubit, DestinationListState>(
          builder: (context, listState) {
            final favoriteIds = context.watch<FavoritesCubit>().state;
            final favorites = listState.items.where((d) => favoriteIds.contains(d.id)).toList();

            if (favorites.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppDimensions.s20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_border_rounded, color: AppColors.softGold, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chưa có điểm đến được lưu',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Lưu lại các danh lam thắng cảnh bạn muốn ghé thăm.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push(RouteNames.destinations),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Khám phá', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final item = favorites[i];
                  return SizedBox(
                    width: 220,
                    child: TourismCard(
                      padding: EdgeInsets.zero,
                      onTap: () => context.push(RouteNames.destinationDetail(item.id)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CoverImage(
                            source: item.coverImage,
                            height: 120,
                            width: double.infinity,
                            radius: AppDimensions.radius16 - 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppDimensions.s12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 13, color: AppColors.softGold),
                                    const SizedBox(width: 3),
                                    Text(
                                      item.ratingAvg.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.address,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookingsTab(BuildContext context) {
    if (widget.userId.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.s32),
        child: EmptyStateWidget(
          icon: Icons.login_rounded,
          title: 'Đăng nhập để xem vé & lịch sử',
          message: 'Vui lòng đăng nhập để đồng bộ vé tham quan và workshop đã đặt.',
          actionLabel: 'Đăng nhập ngay',
          onAction: () => context.push(RouteNames.login),
        ),
      );
    }

    return BlocBuilder<BookingHistoryCubit, BookingListState>(
      builder: (context, state) {
        if (state.status.isLoading && state.bookings.isEmpty) {
          return const LoadingIndicator(message: 'Đang tải danh sách vé...');
        }
        if (state.status.isFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Không thể tải lịch sử', style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<BookingHistoryCubit>().load(widget.userId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.bookings.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.s32),
            child: EmptyStateWidget(
              icon: Icons.confirmation_number_outlined,
              title: 'Chưa có vé hoặc đặt chỗ',
              message: 'Khám phá các workshop làng đá Non Nước và sự kiện du lịch đặc sắc.',
              actionLabel: 'Khám phá workshop',
              onAction: () => context.push(RouteNames.events),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<BookingHistoryCubit>().load(widget.userId),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, AppDimensions.bottomNavClearance),
            itemCount: state.bookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, i) => BookingListTile(booking: state.bookings[i]),
          ),
        );
      },
    );
  }
}

class _QuickCardButton extends StatelessWidget {
  const _QuickCardButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEventItem extends StatelessWidget {
  const _TimelineEventItem({
    required this.time,
    required this.period,
    required this.title,
    required this.location,
    required this.badgeText,
    this.isFirst = false,
    this.isLast = false,
  });

  final String time;
  final String period;
  final String title;
  final String location;
  final String badgeText;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.warmIvory, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TourismCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$period • $time',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.softGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabHeaderDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabHeaderDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar;
  }
}
