import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

enum SnackType { info, success, warning, error }

/// Thông báo nhanh dạng nổi, đồng bộ màu trạng thái pastel.
void showAppSnackBar(BuildContext context, String message, {SnackType type = SnackType.info}) {
  final (IconData icon, Color color) = switch (type) {
    SnackType.success => (Icons.check_circle_rounded, AppColors.success),
    SnackType.warning => (Icons.warning_amber_rounded, AppColors.warning),
    SnackType.error => (Icons.error_rounded, AppColors.error),
    SnackType.info => (Icons.info_rounded, AppColors.primaryPastel),
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
}

/// Hộp thoại xác nhận chuẩn (hủy đặt chỗ, xóa đánh giá...).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final resolvedConfirm = confirmLabel ?? context.tr('common.confirm');
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      scrollable: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.tr('common.close'), style: const TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? AppColors.error : AppColors.primaryTeal,
            minimumSize: const Size(96, 44),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(resolvedConfirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
