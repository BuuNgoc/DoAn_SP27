import 'package:flutter/material.dart';

/// SmartTravel Design System – "Soft Ice-Mint Pastel & Topographic Contour".
///
/// Bảng màu lấy cảm hứng từ vân đá cẩm thạch Ngũ Hành Sơn và mặt biển
/// Sơn Thủy – Tân Trà. Mọi widget trong ứng dụng chỉ dùng màu từ lớp này.
class AppColors {
  AppColors._();

  // ── Nền & bề mặt ───────────────────────────────────────────────────────
  static const Color backgroundIceMint = Color(0xFFF4FAFA);
  static const Color backgroundSecondary = Color(0xFFECF7F7);
  static const Color contourLineColor = Color(0xFFE0EFEF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFDFEEEE);

  // ── Thương hiệu ────────────────────────────────────────────────────────
  static const Color primaryTeal = Color(0xFF24838B);
  static const Color primaryPastel = Color(0xFF58B4BC);
  static const Color accentSoftGold = Color(0xFFE4B363);

  // ── Chữ ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF183438);
  static const Color textSecondary = Color(0xFF627F83);
  static const Color textMuted = Color(0xFF94AEB2);

  // ── Trạng thái (pastel dịu mắt) ───────────────────────────────────────
  static const Color success = Color(0xFF4CAF7A);
  static const Color warning = Color(0xFFF2A65A);
  static const Color error = Color(0xFFE56B6B);

  // ── Gradient & bóng đổ dùng chung ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, primaryPastel],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE4B363), Color(0xFFF1CF8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primaryTeal.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
