import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';

/// Nút trái tim lưu yêu thích (đồng bộ toàn ứng dụng qua [FavoritesCubit]).
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.destinationId, this.size = 40, this.onImage = true});

  final String destinationId;
  final double size;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final saved = context.select((FavoritesCubit c) => c.state.contains(destinationId));
    return Material(
      color: onImage ? Colors.white.withValues(alpha: 0.92) : AppColors.backgroundSecondary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          final added = await context.read<FavoritesCubit>().toggle(destinationId);
          if (context.mounted) {
            showAppSnackBar(
              context,
              added ? 'Đã lưu vào danh sách yêu thích.' : 'Đã bỏ khỏi danh sách yêu thích.',
              type: added ? SnackType.success : SnackType.info,
            );
          }
        },
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(saved),
              color: saved ? AppColors.error : AppColors.textSecondary,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Thẻ điểm đến nổi bật (cuộn ngang trên Trang chủ).
class DestinationFeatureCard extends StatelessWidget {
  const DestinationFeatureCard({super.key, required this.destination, this.width = 260});

  final Destination destination;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push(RouteNames.destinationDetail(destination.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CoverImage(
                  source: destination.coverImage,
                  height: 170,
                  width: double.infinity,
                  radius: 18,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FavoriteButton(destinationId: destination.id, size: 36),
                ),
                Positioned(left: 10, bottom: 10, child: DestinationMediaBadges(destination: destination)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 17, color: AppColors.accentSoftGold),
                      const SizedBox(width: 3),
                      Text(
                        destination.ratingAvg.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        ' (${destination.reviewCount})',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(destination.category.icon, size: 15, color: AppColors.primaryPastel),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          destination.category.label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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

/// Dòng điểm đến gọn (danh sách dọc, yêu thích, kết quả tìm kiếm).
class DestinationListTile extends StatelessWidget {
  const DestinationListTile({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: () => context.push(RouteNames.destinationDetail(destination.id)),
      child: Row(
        children: [
          CoverImage(source: destination.coverImage, width: 96, height: 96, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  destination.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.accentSoftGold),
                    const SizedBox(width: 2),
                    Text(
                      destination.ratingAvg.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                    const SizedBox(width: 10),
                    if (destination.hasVr360)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: PillBadge(label: 'VR360', icon: Icons.threesixty_rounded, fontSize: 10.5),
                      ),
                    if (destination.hasAudioGuide)
                      const PillBadge(
                        label: 'Audio',
                        icon: Icons.headphones_rounded,
                        color: AppColors.primaryPastel,
                        fontSize: 10.5,
                      ),
                  ],
                ),
              ],
            ),
          ),
          FavoriteButton(destinationId: destination.id, size: 36, onImage: false),
        ],
      ),
    );
  }
}

/// Huy hiệu VR360 / Audio Guide trên ảnh bìa.
class DestinationMediaBadges extends StatelessWidget {
  const DestinationMediaBadges({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (destination.hasVr360)
          const PillBadge(
            label: 'VR360',
            icon: Icons.threesixty_rounded,
            color: AppColors.primaryPastel,
            solid: true,
          ),
        if (destination.hasVr360 && destination.hasAudioGuide) const SizedBox(width: 6),
        if (destination.hasAudioGuide)
          const PillBadge(
            label: 'Audio',
            icon: Icons.headphones_rounded,
            color: AppColors.primaryTeal,
            solid: true,
          ),
      ],
    );
  }
}

/// Thanh chip lọc danh mục cuộn ngang.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.showAll = true,
  });

  final DestinationCategory? selected;
  final ValueChanged<DestinationCategory?> onSelected;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (showAll)
        _chip(
          label: 'Tất cả',
          icon: Icons.apps_rounded,
          isSelected: selected == null,
          onTap: () => onSelected(null),
        ),
      for (final c in DestinationCategory.values)
        _chip(label: c.label, icon: c.icon, isSelected: selected == c, onTap: () => onSelected(c)),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.primaryGradient : null,
        color: isSelected ? null : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? Colors.transparent : AppColors.cardBorder),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(icon, size: 17, color: isSelected ? Colors.white : AppColors.primaryTeal),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ô tìm kiếm bo tròn. Khi [readOnly] = true, chạm vào sẽ gọi [onTap].
class RoundedSearchField extends StatelessWidget {
  const RoundedSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.hint = 'Tìm hang động, chùa, bãi biển...',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: AppColors.softShadow),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryTeal),
          suffixIcon: const Icon(Icons.tune_rounded, color: AppColors.textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
        ),
      ),
    );
  }
}
