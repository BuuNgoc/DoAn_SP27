import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../domain/entities/zone_entities.dart';

/// Ảnh bìa lớn của phân khu (dùng trong SliverAppBar).
class ZoneHeroBackground extends StatelessWidget {
  const ZoneHeroBackground({super.key, required this.image, required this.title, required this.tagline});
  final String image;
  final String title;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CoverImage(source: image, radius: 0),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.65)],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 6),
              Text(tagline, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Thẻ địa điểm trong phân khu: nhà hàng, bar, hoạt động biển, dịch vụ...
class ZoneSpotCard extends StatelessWidget {
  const ZoneSpotCard({super.key, required this.spot});
  final ZoneSpot spot;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => ZoneSpotSheet.show(context, spot),
      child: Row(
        children: [
          CoverImage(source: spot.image, width: 92, height: 92, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PillBadge(label: spot.category.label, icon: spot.category.icon, fontSize: 10.5),
                const SizedBox(height: 6),
                Text(spot.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(spot.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.35)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (spot.rating != null) ...[
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.accentSoftGold),
                      Text(' ${spot.rating!.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                      const Text('  ·  ', style: TextStyle(color: AppColors.textMuted)),
                    ],
                    Expanded(
                      child: Text(spot.priceRange,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w700, fontSize: 12.5)),
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

/// Bottom sheet chi tiết địa điểm + chỉ đường + đặt chỗ (nếu có).
class ZoneSpotSheet extends StatelessWidget {
  const ZoneSpotSheet({super.key, required this.spot});
  final ZoneSpot spot;

  static Future<void> show(BuildContext context, ZoneSpot spot) => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: AppColors.surfaceWhite,
        builder: (_) => ZoneSpotSheet(spot: spot),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            CoverImage(source: spot.image, height: 170, width: double.infinity, radius: 20),
            const SizedBox(height: 14),
            Text(spot.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            if (spot.rating != null) RatingStars(rating: spot.rating!, showValue: true),
            const SizedBox(height: 10),
            Text(spot.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 14),
            _Line(icon: Icons.place_rounded, text: spot.address),
            _Line(icon: Icons.schedule_rounded, text: spot.openingHours),
            _Line(icon: Icons.payments_rounded, text: spot.priceRange),
            if (spot.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final t in spot.tags) PillBadge(label: t, color: AppColors.textSecondary)],
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await MapLauncher.openDirections(lat: spot.latitude, lng: spot.longitude);
                      if (!ok && context.mounted) {
                        showAppSnackBar(context, context.tr('destinations.map_open_error'), type: SnackType.error);
                      }
                    },
                    icon: const Icon(Icons.directions_rounded),
                    label: Text(context.tr('map.get_directions')),
                  ),
                ),
                if (spot.bookableServiceId != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(RouteNames.bookingForm(spot.bookableServiceId!));
                      },
                      icon: const Icon(Icons.event_available_rounded),
                      label: Text(context.tr('booking.form_title')),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}

/// Bản đồ thu nhỏ của phân khu: vẽ lưới phố cách điệu và ghim các địa điểm.
class ZoneMiniMap extends StatelessWidget {
  const ZoneMiniMap({super.key, required this.spots, this.height = 220, this.showSea = false});

  final List<ZoneSpot> spots;
  final double height;
  final bool showSea;

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();
    final lats = spots.map((s) => s.latitude);
    final lngs = spots.map((s) => s.longitude);
    final minLat = lats.reduce((a, b) => a < b ? a : b), maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b), maxLng = lngs.reduce((a, b) => a > b ? a : b);
    double nx(double lng) => maxLng == minLng ? 0.5 : 0.12 + 0.76 * (lng - minLng) / (maxLng - minLng);
    double ny(double lat) => maxLat == minLat ? 0.5 : 0.12 + 0.76 * (1 - (lat - minLat) / (maxLat - minLat));

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, c) => Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _StreetGridPainter(showSea: showSea))),
              for (final s in spots)
                Positioned(
                  left: nx(s.longitude) * c.maxWidth - 18,
                  top: ny(s.latitude) * c.maxHeight - 40,
                  child: Tooltip(
                    message: s.name,
                    child: GestureDetector(
                      onTap: () => ZoneSpotSheet.show(context, s),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryTeal, width: 2),
                              boxShadow: AppColors.softShadow,
                            ),
                            child: Icon(s.category.icon, size: 18, color: AppColors.primaryTeal),
                          ),
                          Container(width: 2, height: 6, color: AppColors.primaryTeal),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetGridPainter extends CustomPainter {
  const _StreetGridPainter({required this.showSea});
  final bool showSea;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.backgroundSecondary);
    if (showSea) {
      final sea = Path()
        ..moveTo(size.width * 0.78, 0)
        ..quadraticBezierTo(size.width * 0.7, size.height * 0.5, size.width * 0.82, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0)
        ..close();
      canvas.drawPath(sea, Paint()..color = const Color(0xFFCFE9F1));
    }
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final lane = Paint()
      ..color = AppColors.contourLineColor
      ..strokeWidth = 3;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 8), i.isEven ? road : lane);
    }
    for (var i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x - 10, size.height), i == 3 ? road : lane);
    }
  }

  @override
  bool shouldRepaint(covariant _StreetGridPainter oldDelegate) => oldDelegate.showSea != showSea;
}
