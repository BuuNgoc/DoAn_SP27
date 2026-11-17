import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../destination_discovery/presentation/bloc/destination_cubits.dart';
import '../../domain/entities/review.dart';
import '../bloc/review_cubits.dart';
import '../widgets/review_widgets.dart';

/// [FE-10] Toàn bộ đánh giá của một điểm đến.
class DestinationReviewsScreen extends StatelessWidget {
  const DestinationReviewsScreen({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DestinationReviewsCubit>()..load(destinationId)),
        BlocProvider(create: (_) => sl<DestinationDetailCubit>()..load(destinationId)),
      ],
      child: _ReviewsView(destinationId: destinationId),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  const _ReviewsView({required this.destinationId});
  final String destinationId;

  Future<void> _write(BuildContext context, List<Review> reviews) async {
    final user = await requireLogin(context, reason: context.tr('reviews.login_to_write'));
    if (user == null || !context.mounted) return;
    final mine = reviews.where((r) => r.userId == user.uid).firstOrNull;
    final route = mine == null
        ? RouteNames.writeReview(destinationId)
        : '${RouteNames.writeReview(destinationId)}?reviewId=${mine.id}';
    final changed = await context.push<bool>(route);
    if (changed == true && context.mounted) await context.read<DestinationReviewsCubit>().refresh();
  }

  Future<void> _report(BuildContext context, Review review) async {
    final user = await requireLogin(context, reason: context.tr('reviews.login_to_report'));
    if (user == null || !context.mounted) return;
    final result = await showReportReviewDialog(context);
    if (result == null || !context.mounted) return;
    final error = await context.read<DestinationReviewsCubit>().report(user.uid, review, result.reason, result.note);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      error ?? context.tr('reviews.report_thanks'),
      type: error == null ? SnackType.success : SnackType.warning,
    );
  }

  Future<void> _delete(BuildContext context, String userId, Review review) async {
    final ok = await showConfirmDialog(
      context,
      title: context.tr('reviews.delete_confirm_title'),
      message: context.tr('reviews.delete_confirm_msg'),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final error = await context.read<DestinationReviewsCubit>().delete(userId, review);
    if (!context.mounted) return;
    showAppSnackBar(context, error ?? context.tr('reviews.deleted_success'), type: error == null ? SnackType.success : SnackType.error);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.select((AuthCubit c) => c.state.user?.uid);
    final name = context.select((DestinationDetailCubit c) => c.state.destination?.name);
    return BlocBuilder<DestinationReviewsCubit, ReviewListState>(
      builder: (context, state) {
        final hasMine = userId != null && state.reviews.any((r) => r.userId == userId);
        return TopographicScaffold(
          seed: 61,
          appBar: CustomAppBar(title: context.tr('reviews.title'), subtitle: name),
          floatingActionButton: state.status.isSuccess
              ? FloatingActionButton.extended(
                  onPressed: () => _write(context, state.reviews),
                  icon: Icon(hasMine ? Icons.edit_rounded : Icons.rate_review_rounded),
                  label: Text(hasMine ? context.tr('reviews.edit_your_review') : context.tr('reviews.write_review')),
                )
              : null,
          body: () {
            if (state.status.isLoading) return LoadingIndicator(message: context.tr('reviews.loading_reviews'));
            if (state.status.isFailure) {
              return ErrorViewWidget(
                message: state.errorMessage ?? context.tr('reviews.load_error'),
                onRetry: () => context.read<DestinationReviewsCubit>().load(destinationId),
              );
            }
            final visible = state.visible;
            return RefreshIndicator(
              onRefresh: () => context.read<DestinationReviewsCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                children: [
                  RatingSummaryCard(
                    summary: state.summary,
                    selectedStar: state.starFilter,
                    onStarTap: context.read<DestinationReviewsCubit>().setStarFilter,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final s in ReviewSort.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(s.label),
                              selected: state.sort == s,
                              onSelected: (_) => context.read<DestinationReviewsCubit>().setSort(s),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (state.starFilter != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InputChip(
                        label: Text(context.tr('reviews.only_star_filter', params: {'star': '${state.starFilter}'})),
                        onDeleted: () => context.read<DestinationReviewsCubit>().setStarFilter(state.starFilter),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: EmptyStateWidget(
                        icon: Icons.rate_review_outlined,
                        title: state.reviews.isEmpty ? context.tr('reviews.empty_title') : context.tr('reviews.empty_filtered_title'),
                        message: state.reviews.isEmpty
                            ? context.tr('reviews.empty_message')
                            : context.tr('reviews.empty_filtered_message'),
                      ),
                    ),
                  for (final r in visible) ...[
                    ReviewCard(
                      review: r,
                      isMine: r.userId == userId,
                      onEdit: () => _write(context, state.reviews),
                      onDelete: userId == null ? null : () => _delete(context, userId, r),
                      onReport: () => _report(context, r),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          }(),
        );
      },
    );
  }
}
