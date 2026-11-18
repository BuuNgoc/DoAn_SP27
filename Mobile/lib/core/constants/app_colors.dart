import 'package:flutter/material.dart';

/// NHS360 Shangri-La Luxury Hospitality Design System Tokens.
///
/// Lấy cảm hứng từ phong cách nghỉ dưỡng cao cấp Shangri-La Circle:
/// - Primary: Deep Forest Green (#173F35), Dark Green (#244C40)
/// - Secondary: Warm Ivory (#F8F6F0), Sand Beige (#E8DFD0), Soft Gold (#B69A67)
/// - Text: Primary (#242824), Secondary (#777A73), Muted (#A1A39D)
/// - Surface & Background: White (#FFFFFF), Background (#F8F7F3)
class AppColors {
  AppColors._();

  // ── 1. Luxury Brand Tokens ─────────────────────────────────────────────
  /// Deep Forest Green (#173F35) - Màu chủ đạo sang trọng, trầm mặc của rặng núi Ngũ Hành
  static const Color primary = Color(0xFF173F35);
  /// Dark Green (#244C40)
  static const Color primaryDark = Color(0xFF0F2B24);
  static const Color primaryLight = Color(0xFF244C40);
  /// Deep Forest Green Surface
  static const Color primarySurface = Color(0xFFEBF2EF);

  /// Sand Beige (#E8DFD0)
  static const Color secondary = Color(0xFFE8DFD0);
  static const Color secondaryLight = Color(0xFFF2ECE1);
  static const Color secondaryDark = Color(0xFFC7BCA9);
  /// Warm Ivory (#F8F6F0)
  static const Color secondarySurface = Color(0xFFF8F6F0);
  static const Color warmIvory = Color(0xFFF8F6F0);
  static const Color sandBeige = Color(0xFFE8DFD0);

  /// Soft Gold (#B69A67) - Màu điểm xuyết hoàng gia, cao cấp
  static const Color accent = Color(0xFFB69A67);
  static const Color accentLight = Color(0xFFD4C29A);
  static const Color accentDark = Color(0xFF8F7645);
  static const Color accentSurface = Color(0xFFFBF8F2);
  static const Color softGold = Color(0xFFB69A67);

  // ── 2. Backgrounds & Surfaces ─────────────────────────────────────────
  /// Luxury Background (#F8F7F3)
  static const Color background = Color(0xFFF8F7F3);
  static const Color backgroundSubtle = Color(0xFFF2F0EB);
  /// Pure Card White (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF173F35);

  // ── 3. Typography & Text Hierarchy ────────────────────────────────────
  /// Text Primary (#242824) - Đậm nét, trang nhã
  static const Color textPrimary = Color(0xFF242824);
  /// Text Secondary (#777A73) - Thanh lịch
  static const Color textSecondary = Color(0xFF777A73);
  /// Text Muted (#A1A39D) - Tinh tế
  static const Color textMuted = Color(0xFFA1A39D);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ── 4. Borders & Dividers ─────────────────────────────────────────────
  static const Color border = Color(0xFFE8E5DC);
  static const Color borderSubtle = Color(0xFFF0EFEB);
  static const Color borderActive = Color(0xFFB69A67);

  // ── 5. Semantic States ────────────────────────────────────────────────
  static const Color success = Color(0xFF227855);
  static const Color successSurface = Color(0xFFEBF7F0);
  static const Color warning = Color(0xFFC5892F);
  static const Color warningSurface = Color(0xFFFCF6ED);
  static const Color error = Color(0xFFB93838);
  static const Color errorSurface = Color(0xFFFAEEEE);
  static const Color info = Color(0xFF173F35);
  static const Color infoSurface = Color(0xFFEBF2EF);

  // ── 6. Gradients (Tối giản, Hạn chế, Đậm chất Shangri-La) ───────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF173F35), Color(0xFF244C40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFB69A67), Color(0xFFCBB688)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x33173F35),
      Color(0xA6173F35),
      Color(0xE6173F35),
    ],
    stops: [0.0, 0.4, 0.75, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient subtleCardOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC173F35)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Backward-compatible subtle gradients
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFB69A67), Color(0xFFC5892F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF173F35), Color(0xFF244C40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient auroraGradient = LinearGradient(
    colors: [Color(0xFF173F35), Color(0xFFB69A67)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── 7. Shadows ────────────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF173F35).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF173F35).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: const Color(0xFF173F35).withValues(alpha: 0.16),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Backward-compatible Aliases ───────────────────────────────────────
  static const Color primaryTeal = Color(0xFF173F35);
  static const Color primaryPastel = Color(0xFF244C40);
  static const Color accentSoftGold = Color(0xFFB69A67);
  static const Color backgroundIceMint = Color(0xFFF8F7F3);
  static const Color backgroundSecondary = Color(0xFFF8F6F0);
  static const Color contourLineColor = Color(0xFFE8DFD0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE8E5DC);
}
