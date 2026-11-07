import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';
import '../widgets/destination_widgets.dart';
import 'home_screen.dart';

/// [FE-02] Danh sách điểm đến: tìm kiếm theo từ khóa + lọc theo danh mục.
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DestinationListCubit, DestinationListState>(
      builder: (context, state) {
        final cubit = context.read<DestinationListCubit>();
        return TopographicScaffold(
          appBar: CustomAppBar(
            title: categoryTitle(state.category),
            subtitle: state.status.isSuccess ? '${state.items.length} địa điểm' : null,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: RoundedSearchField(
                  controller: _controller,
                  autofocus: widget.autofocus,
                  onChanged: cubit.search,
                ),
              ),
              CategoryFilterBar(selected: state.category, onSelected: cubit.selectCategory),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DestinationListState state) {
    if (state.status.isLoading) return const LoadingIndicator(message: 'Đang tải điểm đến...');
    if (state.status.isFailure) {
      return ErrorViewWidget(
        message: state.errorMessage ?? '',
        onRetry: () => context.read<DestinationListCubit>().load(category: state.category),
      );
    }
    if (state.items.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.travel_explore_rounded,
        title: 'Không tìm thấy điểm đến phù hợp',
        message: 'Hãy thử từ khóa khác, ví dụ: "hang động", "chùa", "biển".',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => DestinationListTile(destination: state.items[i]),
    );
  }
}
