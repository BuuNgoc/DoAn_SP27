import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../destination_discovery/presentation/widgets/destination_widgets.dart';
import '../../domain/entities/event_entities.dart';
import '../bloc/events_cubits.dart';
import '../widgets/event_widgets.dart';

/// [FE-06] Tìm kiếm, lọc sự kiện & workshop; lối vào cuộc thi điêu khắc đá (FE-16).
class EventWorkshopListScreen extends StatelessWidget {
  const EventWorkshopListScreen({super.key, this.initialKind});

  final EventKind? initialKind;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EventListCubit>()..load(kind: initialKind),
      child: const _EventListView(),
    );
  }
}

class _EventListView extends StatefulWidget {
  const _EventListView();

  @override
  State<_EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<_EventListView> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EventListCubit>();
    return TopographicScaffold(
      seed: 3,
      appBar: const CustomAppBar(title: 'Sự kiện & Workshop', subtitle: 'Trải nghiệm văn hóa Ngũ Hành Sơn'),
      body: BlocBuilder<EventListCubit, EventListState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => cubit.load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                RoundedSearchField(
                  hint: 'Tìm sự kiện, workshop, địa điểm...',
                  onChanged: (v) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 350), () => cubit.search(v));
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: state.kind == null,
                      onSelected: (_) => cubit.selectKind(null),
                    ),
                    for (final k in EventKind.values)
                      ChoiceChip(
                        avatar: Icon(k.icon, size: 16),
                        label: Text(k.label),
                        selected: state.kind == k,
                        onSelected: (_) => cubit.selectKind(k),
                      ),
                    FilterChip(
                      label: const Text('Còn chỗ'),
                      selected: state.onlyAvailable,
                      onSelected: (_) => cubit.toggleOnlyAvailable(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ContestBanner(onTap: () => context.push(RouteNames.contest)),
                const SizedBox(height: 16),
                if (state.status.isLoading && state.events.isEmpty)
                  const Padding(padding: EdgeInsets.all(40), child: LoadingIndicator())
                else if (state.status.isFailure)
                  ErrorViewWidget(message: state.errorMessage ?? 'Không tải được danh sách.', onRetry: cubit.load)
                else if (state.visible.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.event_busy_rounded,
                    title: 'Không có sự kiện phù hợp',
                    message: 'Hãy thử từ khóa khác hoặc bỏ bớt bộ lọc.',
                  )
                else
                  for (final e in state.visible)
                    Padding(padding: const EdgeInsets.only(bottom: 16), child: EventCard(event: e)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContestBanner extends StatelessWidget {
  const _ContestBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      gradient: AppColors.goldGradient,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ĐANG BÌNH CHỌN',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('Cuộc thi Điêu khắc đá Non Nước 2026',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Bình chọn tác phẩm bạn yêu thích →',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 13)),
                ],
              ),
            ),
          ),
          const ClipRRect(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
            child: CoverImage(source: 'assets/images/stone_dragon_carving.jpg', width: 110, height: 110, radius: 0),
          ),
        ],
      ),
    );
  }
}
