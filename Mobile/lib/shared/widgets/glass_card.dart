import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Thẻ kính mờ (glassmorphism nhẹ) đặt trên nền vân địa hình.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 24,
    this.opacity = 0.72,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: AppColors.surfaceWhite.withValues(alpha: 0.9), width: 1.2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
