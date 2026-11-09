import 'package:flutter/material.dart';

/// NHS360 UI/UX Pro Max Tourism Design System Tokens.
///
/// Lấy cảm hứng từ danh thắng Ngũ Hành Sơn:
/// - Sắc xanh biển trời Non Nước (Sky Blue)
/// - Màu ngọc bích non nước cẩm thạch (Emerald Teal)
/// - Sắc cam hoàng hôn & đất nung làng đá mỹ nghệ (Warm Sunset Amber)
/// - Hệ màu trung tính Slate cao cấp, độ tương phản chuẩn WCAG 4.5:1.
class AppColors {
  AppColors._();

  // ── 1. Brand Tokens ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF0284C7); // Sky Blue 600
  static const Color primaryLight = Color(0xFF38BDF8); // Sky Blue 400
  static const Color primaryDark = Color(0xFF0369A1); // Sky Blue 700
  static const Color primarySurface = Color(0xFFF0F9FF); // Sky Blue 50

  static const Color secondary = Color(0xFF0D9488); // Teal 600 (Ngọc Thủy Sơn)
  static const Color secondaryLight = Color(0xFF2DD4BF); // Teal 400
  static const Color secondaryDark = Color(0xFF0F766E); // Teal 700
  static const Color secondarySurface = Color(0xFFF0FDFA); // Teal 50

  static const Color accent = Color(0xFFEA580C); // Sunset Amber / Stone terracotta
  static const Color accentLight = Color(0xFFFB923C); // Amber 400
  static const Color accentSurface = Color(0xFFFFF7ED); // Amber 50

  // ── 2. Backgrounds & Surfaces ─────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Crisp slate 50
  static const Color backgroundSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color surface = Color(0xFFFFFFFF); // Pure card white
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900 for dark cards

  // ── 3. Typography & Text Hierarchy ────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF);

  // ── 4. Borders & Dividers ─────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color borderActive = Color(0xFF38BDF8);

  // ── 5. Semantic States ────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoSurface = Color(0xFFF0F9FF);

  // ── 6. Gradients ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0x990F172A), Color(0xE60F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── 7. Shadows ────────────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: const Color(0xFF0284C7).withValues(alpha: 0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Backward-compatible Aliases ───────────────────────────────────────
  static const Color primaryTeal = Color(0xFF0284C7);
  static const Color primaryPastel = Color(0xFF38BDF8);
  static const Color accentSoftGold = Color(0xFFEA580C);
  static const Color backgroundIceMint = Color(0xFFF8FAFC);
  static const Color backgroundSecondary = Color(0xFFF1F5F9);
  static const Color contourLineColor = Color(0xFFE2E8F0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
}
