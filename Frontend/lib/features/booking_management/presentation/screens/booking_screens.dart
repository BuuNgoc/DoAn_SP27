import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../domain/entities/booking_entities.dart';
import '../bloc/booking_cubits.dart';
import '../widgets/booking_widgets.dart';

/// [FE-07] Xác nhận đặt chỗ thành công kèm mã QR.
class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingDetailCubit>()..load(bookingId),
      child: TopographicScaffold(
        seed: 9,
        appBar: CustomAppBar(title: context.tr('booking.confirmation_title'), showBackButton: false),
        body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
          builder: (context, state) {
            final b = state.booking;
            if (state.status.isFailure) {
              return ErrorViewWidget(message: state.errorMessage ?? context.tr('booking.load_booking_error'));
            }
            if (b == null) return const LoadingIndicator();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.4, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColors.success, size: 54),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  context.tr('booking.confirmation_heading'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'booking.confirmation_subheading',
                    params: {
                      'time': DateFormatter.formatTime(b.sessionAt),
                      'date': DateFormatter.formatWithWeekday(b.sessionAt),
                    },
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                BookingQrCard(booking: b),
                const SizedBox(height: 16),
                BookingSummaryCard(booking: b),
                const SizedBox(height: 20),
                CustomButton(
                  label: context.tr('booking.view_booking_history'),
                  icon: Icons.receipt_long_rounded,
                  onPressed: () => context.pushReplacement(RouteNames.bookingHistory),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        onPressed: () => SocialShareSheet.show(
                          context,
                          title: b.serviceTitle,
                          message: context.tr(
                            'booking.share_booking_message',
                            params: {
                              'title': b.serviceTitle,
                              'date': DateFormatter.formatDateOnly(b.sessionAt),
                            },
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded),
                        label: Text(context.tr('common.share')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        onPressed: () => context.go(RouteNames.explore),
                        icon: const Icon(Icons.home_rounded),
                        label: Text(context.tr('nav.home')),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// [FE-07] Lịch sử đặt chỗ: sắp tới & đã qua/đã hủy.
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.uid ?? '';
    return BlocProvider(
      create: (_) => sl<BookingHistoryCubit>()..load(userId),
      child: DefaultTabController(
        length: 2,
        child: TopographicScaffold(
          appBar: CustomAppBar(
            title: context.tr('booking.history_title'),
            bottom: TabBar(
              tabs: [
                Tab(text: context.tr('booking.tab_upcoming')),
                Tab(text: context.tr('booking.tab_past')),
              ],
            ),
          ),
          body: BlocBuilder<BookingHistoryCubit, BookingListState>(
            builder: (context, state) {
              final cubit = context.read<BookingHistoryCubit>();
              if (state.status.isFailure) {
                return ErrorViewWidget(
                  message: state.errorMessage ?? context.tr('booking.load_history_error'),
                  onRetry: () => cubit.load(userId),
                );
              }
              if (state.status.isLoading && state.bookings.isEmpty) return const LoadingIndicator();
              Widget list(List<Booking> bookings, String emptyText) => RefreshIndicator(
                    onRefresh: () => cubit.load(userId),
                    child: bookings.isEmpty
                        ? ListView(children: [
                            const SizedBox(height: 60),
                            EmptyStateWidget(
                              icon: Icons.event_note_rounded,
                              title: emptyText,
                              actionLabel: context.tr('booking.explore_events'),
                              onAction: () => context.push(RouteNames.events),
                            ),
                          ])
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                            itemCount: bookings.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => BookingListTile(booking: bookings[i]),
                          ),
                  );
              return TabBarView(
                children: [
                  list(state.upcoming, context.tr('booking.empty_upcoming')),
                  list(state.past, context.tr('booking.empty_past')),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// [FE-07] Chi tiết đơn: trạng thái, QR xác nhận, hủy đặt chỗ.
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingDetailCubit>()..load(bookingId),
      child: TopographicScaffold(
        appBar: CustomAppBar(title: context.tr('booking.detail_title')),
        body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
          builder: (context, state) {
            final b = state.booking;
            if (state.status.isFailure) {
              return ErrorViewWidget(message: state.errorMessage ?? context.tr('booking.load_booking_error'));
            }
            if (b == null) return const LoadingIndicator();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                BookingQrCard(booking: b),
                const SizedBox(height: 16),
                BookingSummaryCard(booking: b),
                const SizedBox(height: 12),
                Text(
                  context.tr('booking.booked_at', params: {'time': DateFormatter.formatFull(b.createdAt)}),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                if (b.canCancel)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: state.isCancelling
                        ? null
                        : () async {
                            final cubit = context.read<BookingDetailCubit>();
                            final ok = await showConfirmDialog(
                              context,
                              title: context.tr('booking.cancel_dialog_title'),
                              message: context.tr('booking.cancel_dialog_message', params: {'title': b.serviceTitle}),
                              confirmLabel: context.tr('booking.cancel_booking_btn'),
                              destructive: true,
                            );
                            if (!ok) return;
                            final error = await cubit.cancel();
                            if (!context.mounted) return;
                            showAppSnackBar(
                              context,
                              error ?? context.tr('booking.cancel_success'),
                              type: error == null ? SnackType.success : SnackType.error,
                            );
                          },
                    icon: state.isCancelling
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.cancel_outlined),
                    label: Text(context.tr('booking.cancel_booking_btn')),
                  )
                else if (b.isUpcoming && b.status != BookingStatus.cancelled)
                  Text(
                    context.tr('booking.cannot_cancel_under_2h'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                if (b.status == BookingStatus.completed) ...[
                  const SizedBox(height: 10),
                  CustomButton(
                    label: context.tr('booking.rebook_service_btn'),
                    icon: Icons.replay_rounded,
                    onPressed: () => context.push(RouteNames.bookingForm(b.serviceId)),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
