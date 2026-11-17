import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Widget đánh giá sao du lịch chuẩn NHS360.
class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.totalReviews,
    this.starSize = 16.0,
    this.showText = true,
  });

  final double rating;
  final int? totalReviews;
  final double starSize;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 1; i <= 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              i <= rating
                  ? Icons.star_rounded
                  : (i - 0.5 <= rating ? Icons.star_half_rounded : Icons.star_border_rounded),
              size: starSize,
              color: const Color(0xFFF59E0B),
            ),
          ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (totalReviews != null) ...[
            const SizedBox(width: 3),
            Text(
              '($totalReviews)',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ],
      ],
    );
  }
}

