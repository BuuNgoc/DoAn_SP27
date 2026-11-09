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
                  height: 160,
                  width: double.infinity,
                  radius: AppDimensions.radiusCard - 2,
                ),
                // Badges
                Positioned(
                  top: AppDimensions.s8,
                  left: AppDimensions.s8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasVr360)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xE60F172A),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.view_in_ar_rounded, size: 13, color: AppColors.primaryLight),
                              SizedBox(width: 4),
                              Text(
                                'VR 360°',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hasAudioGuide)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xE60284C7),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.headphones_rounded, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'AUDIO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
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
                    top: AppDimensions.s8,
                    right: AppDimensions.s8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavoriteToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFavorite ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null && category!.isNotEmpty)
                    Text(
                      category!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (rating > 0) ...[
                        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
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
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            location!,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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

