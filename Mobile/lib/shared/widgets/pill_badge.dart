import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Huy hiệu bo tròn nhỏ (VR360, Audio, trạng thái, danh mục...).
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primaryTeal,
    this.background,
    this.solid = false,
    this.fontSize = 11.5,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? background;
  final bool solid;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? Colors.white : color;
    final bg = background ?? (solid ? color : color.withValues(alpha: 0.12));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 3, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: fg, fontSize: fontSize, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
