import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/review.dart';
import '../bloc/review_cubits.dart';
import '../widgets/review_widgets.dart';

/// [FE-10] Quản lý đánh giá cá nhân: xem, sửa, xóa.
class PersonalReviewsScreen extends StatelessWidget {
  const PersonalReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.uid;
    return BlocProvider(
      create: (_) {
        final cubit = sl<MyReviewsCubit>();
        if (userId != null) cubit.load(userId);
        return cubit;
      },
      child: const _PersonalReviewsView(),
    );
  }
}

class _PersonalReviewsView extends StatelessWidget {
  const _PersonalReviewsView();

  Future<void> _edit(BuildContext context, Review r) async {
    final changed = await context.push<bool>('${RouteNames.writeReview(r.destinationId)}?reviewId=${r.id}');
    if (changed == true && context.mounted) await context.read<MyReviewsCubit>().refresh();
  }

  Future<void> _delete(BuildContext context, Review r) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Xóa đánh giá?',
      message: 'Đánh giá cho “${r.destinationName}” sẽ bị xóa vĩnh viễn.',
      confirmLabel: 'Xóa',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final error = await context.read<MyReviewsCubit>().delete(r);
    if (!context.mounted) return;
    showAppSnackBar(context, error ?? 'Đã xóa đánh giá.', type: error == null ? SnackType.success : SnackType.error);
  }

  @override
  Widget build(BuildContext context) {
    return TopographicScaffold(
      seed: 71,
      appBar: const CustomAppBar(title: 'Đánh giá của tôi'),
      body: BlocBuilder<MyReviewsCubit, ReviewListState>(
        builder: (context, state) {
          if (state.status.isLoading) return const LoadingIndicator();
          if (state.status.isFailure) {
            return ErrorViewWidget(
              message: state.errorMessage ?? 'Không tải được đánh giá.',
              onRetry: () => context.read<MyReviewsCubit>().refresh(),
            );
          }
          if (state.reviews.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.rate_review_outlined,
              title: 'Bạn chưa có đánh giá nào',
              message: 'Chia sẻ trải nghiệm tại các điểm đến để giúp du khách khác có chuyến đi trọn vẹn hơn.',
              actionLabel: 'Khám phá điểm đến',
              onAction: () => context.push(RouteNames.destinations),
            );
          }
          final avg = state.summary.average;
          final photoCount = state.reviews.fold<int>(0, (s, r) => s + r.photoCount);
          return RefreshIndicator(
            onRefresh: () => context.read<MyReviewsCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      _Stat(value: '${state.reviews.length}', label: 'Đánh giá'),
                      _Stat(value: avg.toStringAsFixed(1), label: 'Điểm trung bình'),
                      _Stat(value: '$photoCount', label: 'Ảnh đã đăng'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final r in state.reviews) ...[
                  ReviewCard(
                    review: r,
                    isMine: true,
                    showDestination: true,
                    onDestinationTap: () => context.push(RouteNames.destinationDetail(r.destinationId)),
                    onEdit: () => _edit(context, r),
                    onDelete: () => _delete(context, r),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
