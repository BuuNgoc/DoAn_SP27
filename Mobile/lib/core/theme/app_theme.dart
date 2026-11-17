import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// NHS360 UI/UX Pro Max Material 3 Theme.
///
/// Bảng màu & Typography lấy cảm hứng từ thiên nhiên Ngũ Hành Sơn:
/// Biển Non Nước, rặng đá cẩm thạch huyền bí, hoàng hôn và di sản văn hóa.
class AppTheme {
  AppTheme._();

  static const double _radius = AppDimensions.radiusCard;

  /// Danh sách font dự phòng cho đa ngôn ngữ vi/en/ko/zh.
  static const List<String> cjkFontFallback = [
    'Roboto',
    'Noto Sans',
    'Noto Sans CJK KR',
    'Noto Sans CJK SC',
    'Noto Sans KR',
    'Noto Sans SC',
    'sans-serif',
  ];

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySurface,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondarySurface,
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentSurface,
      onTertiaryContainer: const Color(0xFF7C2D12),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    const baseText = TextStyle(
      color: AppColors.textPrimary,
      height: 1.4,
      fontFamilyFallback: cjkFontFallback,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamilyFallback: cjkFontFallback,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displayLarge: baseText.copyWith(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.6),
        displayMedium: baseText.copyWith(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        displaySmall: baseText.copyWith(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.4),
        headlineLarge: baseText.copyWith(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        headlineMedium: baseText.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        headlineSmall: baseText.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        titleLarge: baseText.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: baseText.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        titleSmall: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        bodyLarge: baseText.copyWith(fontSize: 16, height: 1.5),
        bodyMedium: baseText.copyWith(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
        bodySmall: baseText.copyWith(fontSize: 12, height: 1.4, color: AppColors.textMuted),
        labelLarge: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: baseText.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: baseText.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          fontFamilyFallback: cjkFontFallback,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamilyFallback: cjkFontFallback,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamilyFallback: cjkFontFallback,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: AppColors.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamilyFallback: cjkFontFallback,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamilyFallback: cjkFontFallback,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontFamilyFallback: cjkFontFallback),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontFamilyFallback: cjkFontFallback),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundSubtle,
        selectedColor: AppColors.primarySurface,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          fontFamilyFallback: cjkFontFallback,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          fontFamilyFallback: cjkFontFallback,
        ),
        checkmarkColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.primarySurface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMuted,
            size: 24,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMuted,
            fontFamilyFallback: cjkFontFallback,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusSheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: roundedShape,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          fontFamilyFallback: cjkFontFallback,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        trackHeight: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.borderSubtle,
      ),
    );
  }
}
