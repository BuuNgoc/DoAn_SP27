import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Material 3 theme – nền Ice-Mint, bo góc 18px, bóng đổ cực nhẹ và AppBar
/// trong suốt để lộ lớp vân địa hình phía sau.
class AppTheme {
  AppTheme._();

  static const double _radius = 18;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryTeal,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primaryTeal,
      onPrimary: Colors.white,
      secondary: AppColors.primaryPastel,
      tertiary: AppColors.accentSoftGold,
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      outline: AppColors.cardBorder,
      outlineVariant: AppColors.cardBorder,
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    const baseText = TextStyle(color: AppColors.textPrimary, height: 1.35);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundIceMint,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displaySmall: baseText.copyWith(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineSmall: baseText.copyWith(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        titleLarge: baseText.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: baseText.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        titleSmall: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        bodyLarge: baseText.copyWith(fontSize: 16),
        bodyMedium: baseText.copyWith(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: baseText.copyWith(fontSize: 12, color: AppColors.textMuted),
        labelLarge: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: baseText.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
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
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 52),
          shape: roundedShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          minimumSize: const Size(64, 52),
          shape: roundedShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          minimumSize: const Size(64, 52),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.4),
          shape: roundedShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedColor: AppColors.primaryTeal,
        side: const BorderSide(color: AppColors.cardBorder),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.backgroundSecondary,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryTeal
                : AppColors.textMuted,
            size: 24,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryTeal
                : AppColors.textMuted,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.cardBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shape: roundedShape,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primaryTeal,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primaryTeal,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.cardBorder, thickness: 1, space: 1),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primaryTeal,
        inactiveTrackColor: AppColors.backgroundSecondary,
        thumbColor: AppColors.primaryTeal,
        trackHeight: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryTeal,
        linearTrackColor: AppColors.backgroundSecondary,
      ),
    );
  }
}
