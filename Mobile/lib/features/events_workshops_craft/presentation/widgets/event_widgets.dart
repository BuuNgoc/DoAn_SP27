import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../domain/entities/event_entities.dart';

/// Thanh hiển thị số chỗ còn trống (Capacity).
class CapacityIndicator extends StatelessWidget {
  const CapacityIndicator({super.key, required this.event, this.compact = false});

  final EventWorkshop event;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = event.isFull
        ? AppColors.error
        : (event.fillRate >= 0.75 ? AppColors.warning : AppColors.success);
    final label = event.isFull
        ? context.tr('events.capacity_full')
        : context.tr(
            'events.remaining_slots',
            params: {'remaining': '${event.remainingSlots}', 'capacity': '${event.capacity}'},
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_seat_rounded, size: 15, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: compact ? 12 : 13)),
            if (!compact && !event.isFull && event.fillRate >= 0.75) ...[
              const SizedBox(width: 6),
              Text(context.tr('events.almost_full'), style: const TextStyle(color: AppColors.warning, fontSize: 12)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: event.fillRate.clamp(0, 1),
            minHeight: compact ? 5 : 8,
            color: color,
            backgroundColor: AppColors.backgroundSecondary,
          ),
        ),
      ],
    );
  }
}

/// Nhãn ngày dạng lịch nhỏ.
class DateBadge extends StatelessWidget {
  const DateBadge({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${date.day}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.1)),
          Text(
            context.tr('common.month_short', params: {'month': '${date.month}'}),
            style: const TextStyle(fontSize: 11, color: AppColors.primaryTeal, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Thẻ sự kiện/workshop dạng danh sách.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final EventWorkshop event;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push(RouteNames.eventDetail(event.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: CoverImage(source: event.coverImage, height: 150, width: double.infinity, radius: 0),
              ),
              Positioned(left: 12, top: 12, child: DateBadge(date: event.startAt)),
              Positioned(
                right: 12,
                top: 12,
                child: PillBadge(
                  label: event.kind.label,
                  icon: event.kind.icon,
                  solid: true,
                  color: event.kind == EventKind.workshop ? AppColors.primaryTeal : AppColors.accentSoftGold,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormatter.formatTime(event.startAt)} – ${DateFormatter.formatTime(event.endAt)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.place_outlined, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(event.venue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: CapacityIndicator(event: event, compact: true)),
                    const SizedBox(width: 16),
                    Text(
                      CurrencyFormatter.vnd(event.price),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryTeal, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
