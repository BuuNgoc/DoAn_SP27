import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
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
        appBar: const CustomAppBar(title: 'Đặt chỗ thành công', showBackButton: false),
        body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
          builder: (context, state) {
            final b = state.booking;
            if (state.status.isFailure) return ErrorViewWidget(message: state.errorMessage ?? 'Không tải được đơn.');
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
                const Text(
                  'Cảm ơn bạn! Đơn đặt chỗ đã được ghi nhận.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hẹn gặp bạn lúc ${DateFormatter.formatTime(b.sessionAt)}, ${DateFormatter.formatWithWeekday(b.sessionAt)}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                BookingQrCard(booking: b),
                const SizedBox(height: 16),
                BookingSummaryCard(booking: b),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Xem lịch sử đặt chỗ',
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
                          message: 'Mình vừa đặt “${b.serviceTitle}” tại Ngũ Hành Sơn qua SmartTravel! '
                              '🗓 ${DateFormatter.formatDateOnly(b.sessionAt)} #SmartTravel',
                        ),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Chia sẻ'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        onPressed: () => context.go(RouteNames.explore),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Trang chủ'),
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
          appBar: const CustomAppBar(
            title: 'Lịch sử đặt chỗ',
            bottom: TabBar(tabs: [Tab(text: 'Sắp tới'), Tab(text: 'Đã qua / Đã hủy')]),
          ),
          body: BlocBuilder<BookingHistoryCubit, BookingListState>(
            builder: (context, state) {
              final cubit = context.read<BookingHistoryCubit>();
              if (state.status.isFailure) {
                return ErrorViewWidget(message: state.errorMessage ?? 'Không tải được.', onRetry: () => cubit.load(userId));
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
                              actionLabel: 'Khám phá sự kiện',
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
                  list(state.upcoming, 'Bạn chưa có lịch đặt chỗ sắp tới'),
                  list(state.past, 'Chưa có đơn nào đã qua'),
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
        appBar: const CustomAppBar(title: 'Chi tiết đặt chỗ'),
        body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
          builder: (context, state) {
            final b = state.booking;
            if (state.status.isFailure) return ErrorViewWidget(message: state.errorMessage ?? 'Không tải được đơn.');
            if (b == null) return const LoadingIndicator();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                BookingQrCard(booking: b),
                const SizedBox(height: 16),
                BookingSummaryCard(booking: b),
                const SizedBox(height: 12),
                Text('Đặt lúc ${DateFormatter.formatFull(b.createdAt)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
                              title: 'Hủy đặt chỗ?',
                              message: 'Bạn có chắc muốn hủy “${b.serviceTitle}”? Thao tác này không thể hoàn tác.',
                              confirmLabel: 'Hủy đặt chỗ',
                              destructive: true,
                            );
                            if (!ok) return;
                            final error = await cubit.cancel();
                            if (!context.mounted) return;
                            showAppSnackBar(
                              context,
                              error ?? 'Đã hủy đặt chỗ thành công.',
                              type: error == null ? SnackType.success : SnackType.error,
                            );
                          },
                    icon: state.isCancelling
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.cancel_outlined),
                    label: const Text('Hủy đặt chỗ'),
                  )
                else if (b.isUpcoming && b.status != BookingStatus.cancelled)
                  const Text(
                    'Đơn không thể hủy khi còn dưới 2 giờ trước giờ bắt đầu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                if (b.status == BookingStatus.completed) ...[
                  const SizedBox(height: 10),
                  CustomButton(
                    label: 'Đặt lại dịch vụ này',
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
