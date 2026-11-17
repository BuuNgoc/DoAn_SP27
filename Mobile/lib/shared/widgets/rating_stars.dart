import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

/// Hiển thị số sao (hỗ trợ nửa sao) màu Soft Gold.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16, this.showValue = false});

  final double rating;
  final double size;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final stars = List<Widget>.generate(5, (i) {
      final value = rating - i;
      final icon = value >= 1
          ? Icons.star_rounded
          : value >= 0.5
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded;
      return Icon(icon, size: size, color: AppColors.accentSoftGold);
    });
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Bộ chọn số sao (1–5) cho màn hình viết đánh giá.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({super.key, required this.value, required this.onChanged, this.size = 40});

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  static const _labelKeys = [
    'core.rating_1',
    'core.rating_2',
    'core.rating_3',
    'core.rating_4',
    'core.rating_5',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final selected = i < value;
            return IconButton(
              onPressed: () => onChanged(i + 1),
              iconSize: size,
              icon: AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  selected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: selected ? AppColors.accentSoftGold : AppColors.textMuted,
                ),
              ),
            );
          }),
        ),
        Text(
          value == 0 ? context.tr('core.rating_tap_hint') : context.tr(_labelKeys[value - 1]),
          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
