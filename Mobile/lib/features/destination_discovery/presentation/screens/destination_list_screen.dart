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
import '../../../../shared/widgets/tourism_search_bar.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';
import '../widgets/destination_widgets.dart';

/// [Redesign Shangri-La Editorial] Màn hình Khám Phá (Explore Screen).
/// Phong cách: Tạp chí du lịch cao cấp (Editorial Travel Magazine):
/// - Header "Khám phá" thanh lịch
/// - Minimalist Luxury Search Bar
/// - Bộ lọc phân loại: Tất cả, Địa điểm, Khách sạn, Ẩm thực, Văn hóa, Trải nghiệm
/// - Layout xen kẽ nhịp nhàng giữa Large Feature Cards, Horizontal Cards và Editorial Sections
class DestinationListScreen extends StatelessWidget {
  const DestinationListScreen({super.key, this.initialCategory, this.autofocusSearch = false});

  final DestinationCategory? initialCategory;
  final bool autofocusSearch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DestinationListCubit>()..load(category: initialCategory),
      child: _DestinationListView(autofocus: autofocusSearch),
    );
  }
}

class _DestinationListView extends StatefulWidget {
  const _DestinationListView({required this.autofocus});

  final bool autofocus;

  @override
  State<_DestinationListView> createState() => _DestinationListViewState();
}

class _DestinationListViewState extends State<_DestinationListView> {
  final _controller = TextEditingController();
  int _selectedFilterIndex = 0;

  static const List<String> _filters = [
    'Tất cả',
    'Địa điểm',
    'Khách sạn',
    'Ẩm thực',
    'Văn hóa',
    'Trải nghiệm',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onFilterTap(int index, DestinationListCubit cubit) {
    setState(() => _selectedFilterIndex = index);
    DestinationCategory? cat;
    switch (index) {
      case 1: // Địa điểm
        cat = DestinationCategory.mountainCave;
        break;
      case 2: // Khách sạn / Nghỉ dưỡng
        cat = DestinationCategory.beach;
        break;
      case 3: // Ẩm thực
        cat = DestinationCategory.anThuong;
        break;
      case 4: // Văn hóa
        cat = DestinationCategory.pagoda;
        break;
      case 5: // Trải nghiệm
        cat = DestinationCategory.craftVillage;
        break;
      default:
        cat = null;
    }
    cubit.selectCategory(cat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DestinationListCubit, DestinationListState>(
          builder: (context, state) {
            final cubit = context.read<DestinationListCubit>();

            return CustomScrollView(
              slivers: [
                // ── 1. Editorial Header ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'EDITORIAL TRAVEL GUIDE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            if (Navigator.of(context).canPop())
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textPrimary),
                                onPressed: () => Navigator.of(context).maybePop(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Khám phá',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (state.status.isSuccess)
                              Text(
                                '${state.items.length} điểm đến tuyển chọn',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 2. Search Field ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: TourismSearchBar(
                      controller: _controller,
                      hintText: 'Tìm địa điểm, hang động, chùa cổ...',
                      onChanged: cubit.search,
                    ),
                  ),
                ),

                // ── 3. Category Filter Chips (Tất cả, Địa điểm, Khách sạn,...) ──
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final isSelected = i == _selectedFilterIndex;
                        return InkWell(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          onTap: () => _onFilterTap(i, cubit),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              _filters[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── 4. Alternating Magazine Content ─────────────────────────────
                _buildSliverContent(context, state),

                const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.bottomNavClearance)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverContent(BuildContext context, DestinationListState state) {
    if (state.status.isLoading) {
      return const SliverFillRemaining(
        child: LoadingIndicator(message: 'Đang tải danh sách điểm đến tuyển chọn...'),
      );
    }
    if (state.status.isFailure) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? 'Không thể tải điểm đến', style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.read<DestinationListCubit>().load(category: state.category),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.travel_explore_rounded,
          title: 'Không tìm thấy điểm đến',
          message: 'Hãy thử đổi từ khóa tìm kiếm hoặc chọn danh mục khác.',
        ),
      );
    }

    // Alternating magazine layout
    final items = state.items;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final d = items[i];
            final layoutPattern = i % 3;

            if (layoutPattern == 0) {
              // Pattern 0: Large Feature Card
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _EditorialLargeCard(destination: d),
              );
            } else if (layoutPattern == 1) {
              // Pattern 1: Horizontal Card
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _EditorialHorizontalCard(destination: d),
              );
            } else {
              // Pattern 2: Immersive Full Bleed Card
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _EditorialBannerCard(destination: d),
              );
            }
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

/// Thẻ lớn (Large Feature Card) trong tạp chí
class _EditorialLargeCard extends StatelessWidget {
  const _EditorialLargeCard({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: EdgeInsets.zero,
      radius: AppDimensions.radius20,
      onTap: () => context.push(RouteNames.destinationDetail(destination.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CoverImage(
                source: destination.coverImage,
                height: 210,
                width: double.infinity,
                radius: AppDimensions.radius20 - 2,
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: AppColors.softGold.withValues(alpha: 0.7), width: 0.8),
                  ),
                  child: Text(
                    destination.category.label.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.warmIvory,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: FavoriteButton(destinationId: destination.id, size: 38),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.softGold),
                    const SizedBox(width: 3),
                    Text(
                      destination.ratingAvg.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 4),
                    Text('(${destination.reviewCount} đánh giá)', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const Spacer(),
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: Text(
                        destination.address,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  destination.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  destination.shortDescription,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  maxLines: 2,
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

/// Thẻ ngang (Horizontal Card)
class _EditorialHorizontalCard extends StatelessWidget {
  const _EditorialHorizontalCard({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: EdgeInsets.zero,
      radius: AppDimensions.radius16,
      onTap: () => context.push(RouteNames.destinationDetail(destination.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CoverImage(
                source: destination.coverImage,
                width: 125,
                height: 135,
                radius: AppDimensions.radius16 - 2,
              ),
              Positioned(
                top: 8,
                left: 8,
                child: FavoriteButton(destinationId: destination.id, size: 30),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.category.label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination.shortDescription,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.softGold),
                      const SizedBox(width: 3),
                      Text(
                        destination.ratingAvg.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      if (destination.hasVr360)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VR 360°',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ Editorial Banner (Editorial Section Card)
class _EditorialBannerCard extends StatelessWidget {
  const _EditorialBannerCard({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
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
            CoverImage(
              source: destination.coverImage,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.5),
                    AppColors.primary.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.softGold,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      destination.category.label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination.shortDescription,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: () => context.push(RouteNames.destinationDetail(destination.id)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.warmIvory,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                      ),
                      child: const Text('Xem chi tiết', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
