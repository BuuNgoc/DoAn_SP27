import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'cover_image.dart';

/// Thẻ Card chuẩn trong Design System NHS360.
class TourismCard extends StatelessWidget {
  const TourismCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = AppDimensions.radiusCard,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.elevation = 0,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double elevation;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 1.0,
        ),
        boxShadow: elevation > 0 ? AppColors.cardShadow : AppColors.softShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    if (margin != null) {
      cardContent = Padding(padding: margin!, child: cardContent);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: clipBehavior,
      child: cardContent,
    );
  }
}

/// Thẻ hiển thị Khách sạn & Nghỉ dưỡng cao cấp (Hotel Card - Shangri-La Hospitality Style).
class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.pricePerNight,
    this.rating = 4.9,
    this.reviewCount = 120,
    this.stars = 5,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onBookingTap,
    this.onTap,
    this.width,
  });

  final String name;
  final String imageUrl;
  final String location;
  final String pricePerNight;
  final double rating;
  final int reviewCount;
  final int stars;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onBookingTap;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 280,
      child: TourismCard(
        padding: EdgeInsets.zero,
        radius: AppDimensions.radius16,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CoverImage(
                  source: imageUrl,
                  height: 170,
                  width: double.infinity,
                  radius: AppDimensions.radius16 - 2,
                ),
                // Star badge
                Positioned(
                  top: AppDimensions.s12,
                  left: AppDimensions.s12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.softGold.withValues(alpha: 0.6), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: AppColors.softGold),
                        const SizedBox(width: 3),
                        Text(
                          '$stars-STAR LUXURY',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite Button
                if (onFavoriteToggle != null)
                  Positioned(
                    top: AppDimensions.s12,
                    right: AppDimensions.s12,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavoriteToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFavorite ? AppColors.error : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.softGold),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giá từ',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Flexible(
                                  child: Text(
                                    pricePerNight,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Text(
                                  ' /đêm',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: onBookingTap ?? onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                          ),
                        ),
                        child: const Text(
                          'Đặt phòng',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ Trải nghiệm Bản sắc Địa phương (Experience Card - Shangri-La Editorial Style).
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.duration,
    required this.price,
    this.category,
    this.rating = 4.9,
    this.reviewCount = 80,
    this.onTap,
    this.onActionTap,
    this.width,
  });

  final String title;
  final String imageUrl;
  final String location;
  final String duration;
  final String price;
  final String? category;
  final double rating;
  final int reviewCount;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 300,
      child: TourismCard(
        padding: EdgeInsets.zero,
        radius: AppDimensions.radius16,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CoverImage(
                  source: imageUrl,
                  height: 180,
                  width: double.infinity,
                  radius: AppDimensions.radius16 - 2,
                ),
                // Gradient overlay for editorial look
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radius16 - 2)),
                      gradient: const LinearGradient(
                        colors: [Colors.transparent, Color(0x66000000)],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                if (category != null)
                  Positioned(
                    top: AppDimensions.s12,
                    left: AppDimensions.s12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(color: AppColors.softGold.withValues(alpha: 0.7), width: 0.8),
                      ),
                      child: Text(
                        category!.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.warmIvory,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: AppDimensions.s12,
                  left: AppDimensions.s12,
                  right: AppDimensions.s12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded, size: 12, color: AppColors.sandBeige),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: AppColors.softGold),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chi phí',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: onActionTap ?? onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                          ),
                        ),
                        child: const Text(
                          'Khám phá',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ Editorial phong cách Tạp chí Du lịch Shangri-La (Editorial Feature Card).
class EditorialFeatureCard extends StatelessWidget {
  const EditorialFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.tag = 'ĐẶC BIỆT',
    this.buttonText = 'Khám phá ngay',
    this.onTap,
    this.height = 240,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String tag;
  final String buttonText;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CoverImage(
              source: imageUrl,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.55),
                    AppColors.primary.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softGold,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.warmIvory,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: Text(
                        buttonText,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ hiển thị Điểm đến du lịch (Destination Card) chuẩn UX Du lịch Ngũ Hành Sơn.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.location,
    this.hasVr360 = false,
    this.hasAudioGuide = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
    this.width,
    this.height,
  });

  final String title;
  final String imageUrl;
  final String? category;
  final double rating;
  final int reviewCount;
  final String? location;
  final bool hasVr360;
  final bool hasAudioGuide;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TourismCard(
        padding: EdgeInsets.zero,
        radius: AppDimensions.radius16,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with Overlays
            Stack(
              children: [
                CoverImage(
                  source: imageUrl,
                  height: 170,
                  width: double.infinity,
                  radius: AppDimensions.radius16 - 2,
                ),
                // Badges
                Positioned(
                  top: AppDimensions.s12,
                  left: AppDimensions.s12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasVr360)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: AppColors.softGold.withValues(alpha: 0.5), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_in_ar_rounded, size: 12, color: AppColors.softGold),
                              SizedBox(width: 4),
                              Text(
                                'VR 360°',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hasAudioGuide)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.headphones_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'AUDIO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Favorite Button
                if (onFavoriteToggle != null)
                  Positioned(
                    top: AppDimensions.s12,
                    right: AppDimensions.s12,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavoriteToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFavorite ? AppColors.error : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null && category!.isNotEmpty)
                    Text(
                      category!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (rating > 0) ...[
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.softGold),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (reviewCount > 0) ...[
                          const SizedBox(width: 3),
                          Text(
                            '($reviewCount)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                      ],
                      if (location != null) ...[
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ Sự kiện Du lịch (Event Card).
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.dateText,
    required this.location,
    this.priceText,
    this.availableSlots,
    this.onTap,
  });

  final String title;
  final String imageUrl;
  final String dateText;
  final String location;
  final String? priceText;
  final int? availableSlots;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverImage(
            source: imageUrl,
            width: 110,
            height: 120,
            radius: AppDimensions.radiusCard - 2,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (availableSlots != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: availableSlots! > 5 ? AppColors.successSurface : AppColors.errorSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Còn $availableSlots chỗ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: availableSlots! > 5 ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                    ],
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

/// Thẻ Trải nghiệm Làng nghề Điêu khắc Đá Non Nước (Workshop Card).
class WorkshopCard extends StatelessWidget {
  const WorkshopCard({
    super.key,
    required this.title,
    required this.artisanName,
    required this.imageUrl,
    required this.durationText,
    this.priceText,
    this.onTap,
  });

  final String title;
  final String artisanName;
  final String imageUrl;
  final String durationText;
  final String? priceText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CoverImage(
                source: imageUrl,
                height: 140,
                width: double.infinity,
                radius: AppDimensions.radiusCard - 2,
              ),
              Positioned(
                top: AppDimensions.s8,
                left: AppDimensions.s8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.handyman_rounded, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'LÀNG ĐÁ NON NƯỚC',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Nghệ nhân: $artisanName',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(
                      durationText,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
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

