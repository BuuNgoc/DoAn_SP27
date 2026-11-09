import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../domain/entities/event_entities.dart';
import '../bloc/events_cubits.dart';
import '../widgets/event_widgets.dart';

/// [FE-06] Chi tiết sự kiện/workshop: lịch trình, vị trí, số chỗ trống, đặt chỗ (FE-07).
class EventWorkshopDetailScreen extends StatelessWidget {
  const EventWorkshopDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EventDetailCubit>()..load(eventId),
      child: BlocBuilder<EventDetailCubit, DetailState<EventWorkshop>>(
        builder: (context, state) {
          if (state.status.isFailure) {
            return TopographicScaffold(
              appBar: const CustomAppBar(title: ''),
              body: ErrorViewWidget(
                message: state.errorMessage ?? context.tr('events.load_detail_error'),
                onRetry: () => context.read<EventDetailCubit>().load(eventId),
              ),
            );
          }
          final e = state.data;
          if (e == null) {
            return const TopographicScaffold(appBar: CustomAppBar(title: ''), body: LoadingIndicator());
          }
          return _EventDetailView(event: e, onRefresh: () => context.read<EventDetailCubit>().load(eventId));
        },
      ),
    );
  }
}

class _EventDetailView extends StatelessWidget {
  const _EventDetailView({required this.event, required this.onRefresh});

  final EventWorkshop event;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final sameDay = e.startAt.year == e.endAt.year && e.startAt.month == e.endAt.month && e.startAt.day == e.endAt.day;
    final dateText = sameDay
        ? DateFormatter.formatWithWeekday(e.startAt)
        : '${DateFormatter.formatDateOnly(e.startAt)} – ${DateFormatter.formatDateOnly(e.endAt)}';

    return TopographicScaffold(
      bottomNavigationBar: _BookingBar(event: e, onBooked: onRefresh),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.backgroundIceMint,
            leadingWidth: 60,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: context.tr('common.back'),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            actions: [
              CircleIconButton(
                icon: Icons.ios_share_rounded,
                tooltip: context.tr('common.share'),
                onPressed: () => SocialShareSheet.show(
                  context,
                  title: e.title,
                  message: '${e.title}\n🗓 $dateText · ${DateFormatter.formatTime(e.startAt)}\n📍 ${e.venue}\n#SmartTravel #NguHanhSon',
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(background: CoverImage(source: e.coverImage, radius: 0)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PillBadge(label: e.kind.label, icon: e.kind.icon),
                      PillBadge(label: e.category, color: AppColors.textSecondary),
                      if (e.price == 0) PillBadge(label: context.tr('common.free'), color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(e.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(e.summary, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: [
                        _Info(icon: Icons.calendar_month_rounded, label: context.tr('events.date_label'), value: dateText),
                        const Divider(height: 20),
                        _Info(
                          icon: Icons.schedule_rounded,
                          label: context.tr('events.time_label'),
                          value: '${DateFormatter.formatTime(e.startAt)} – ${DateFormatter.formatTime(e.endAt)}',
                        ),
                        const Divider(height: 20),
                        _Info(icon: Icons.place_rounded, label: e.venue, value: e.address),
                        const Divider(height: 20),
                        _Info(icon: Icons.apartment_rounded, label: context.tr('events.organizer_label'), value: e.organizer),
                        const Divider(height: 20),
                        CapacityIndicator(event: e),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(context.tr('destinations.overview_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(e.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                  if (e.schedule.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(context.tr('events.schedule_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 10),
                    for (final s in e.schedule)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: AppColors.primaryPastel, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(s, style: const TextStyle(height: 1.45))),
                          ],
                        ),
                      ),
                  ],
                  if (e.includes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(context.tr('events.includes_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final i in e.includes)
                          Chip(
                            avatar: const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                            label: Text(i),
                          ),
                      ],
                    ),
                  ],
                  if (e.artisanId != null) ...[
                    const SizedBox(height: 20),
                    AppCard(
                      onTap: () => context.push(RouteNames.artisan(e.artisanId!)),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundImage: AssetImage('assets/images/artisan_workshop.jpg'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.tr('events.artisan_guide_label'), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                Text(context.tr('events.view_artisan_profile'), style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    onPressed: () async {
                      final ok = await MapLauncher.openDirections(lat: e.latitude, lng: e.longitude);
                      if (!ok && context.mounted) {
                        showAppSnackBar(context, context.tr('common.map_launch_error'), type: SnackType.error);
                      }
                    },
                    icon: const Icon(Icons.directions_rounded),
                    label: Text(context.tr('events.directions_to_venue')),
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

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryTeal, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.event, required this.onBooked});

  final EventWorkshop event;
  final VoidCallback onBooked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('events.price_from'), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text(
                event.price == 0
                    ? context.tr('common.free')
                    : '${CurrencyFormatter.vnd(event.price)}${context.tr('events.per_person_suffix')}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.primaryTeal),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              label: event.isFull
                  ? context.tr('events.capacity_full')
                  : (event.price == 0 ? context.tr('events.register_join') : context.tr('events.book_now')),
              icon: event.isFull ? Icons.block_rounded : Icons.event_available_rounded,
              onPressed: event.isFull || !event.isUpcoming
                  ? null
                  : () async {
                      await context.push(RouteNames.bookingForm(event.id));
                      onBooked();
                    },
            ),
          ),
        ],
      ),
    );
  }
}
