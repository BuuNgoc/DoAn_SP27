import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../bloc/destination_cubits.dart';
import '../widgets/destination_widgets.dart';

/// [FE-02] Địa điểm yêu thích – id lưu trong Hive nên vẫn xem được khi ngoại tuyến.
class SavedFavoritesScreen extends StatelessWidget {
  const SavedFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DestinationListCubit>()..load(),
      child: TopographicScaffold(
        appBar: const CustomAppBar(title: 'Địa điểm yêu thích', subtitle: 'Xem được cả khi ngoại tuyến'),
        body: BlocBuilder<DestinationListCubit, DestinationListState>(
          builder: (context, listState) {
            final favoriteIds = context.watch<FavoritesCubit>().state;
            if (listState.status.isLoading) return const LoadingIndicator();
            if (listState.status.isFailure) {
              return ErrorViewWidget(
                message: listState.errorMessage ?? '',
                onRetry: () => context.read<DestinationListCubit>().load(),
              );
            }
            final items = listState.items.where((d) => favoriteIds.contains(d.id)).toList();
            if (items.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.favorite_border_rounded,
                title: 'Chưa có địa điểm yêu thích',
                message: 'Chạm vào biểu tượng trái tim ở mỗi điểm đến để lưu lại cho chuyến đi của bạn.',
                actionLabel: 'Khám phá ngay',
                onAction: () => context.push(RouteNames.destinations),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => DestinationListTile(destination: items[i]),
            );
          },
        ),
      ),
    );
  }
}
