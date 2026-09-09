import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_geometry.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.signal,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.signalWash,
      onPrimaryContainer: AppColors.signalLight,
      secondary: AppColors.signalLight,
      onSecondary: AppColors.ground,
      surface: AppColors.ground,
      onSurface: AppColors.ink,
      surfaceContainerLowest: AppColors.ground,
      surfaceContainer: AppColors.sheet,
      surfaceContainerHigh: AppColors.row,
      onSurfaceVariant: AppColors.inkBody,
      error: AppColors.low,
      onError: AppColors.ground,
      outline: AppColors.hairline,
      outlineVariant: AppColors.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ground,
      canvasColor: AppColors.ground,
      textTheme: AppTypography.textTheme,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.section,
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.hairline,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTypography.section,
        contentTextStyle: AppTypography.body,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.signal,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(AppSizes.buttonPrimary),
          textStyle: AppTypography.buttonPrimary,
          shape: const StadiumBorder(),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.ground,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppSizes.buttonSecondary),
          textStyle: AppTypography.buttonSecondary,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.signalLight,
          textStyle: AppTypography.buttonSecondary,
          minimumSize: const Size(0, AppSizes.minTap),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inkBody,
          backgroundColor: AppColors.fillStrong,
          minimumSize: const Size.fromHeight(AppSizes.buttonGhost),
          textStyle: AppTypography.buttonSecondary,
          side: BorderSide.none,
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.row,
        hintStyle: AppTypography.body.copyWith(color: AppColors.inkMeta),
        labelStyle: AppTypography.body,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.tileAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.tileAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.tileAll,
          borderSide: BorderSide(color: AppColors.signal, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fillMuted,
        selectedColor: AppColors.signalWash,
        side: BorderSide.none,
        labelStyle: AppTypography.body.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.inkBody,
          height: 1.0,
        ),
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.row,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.ink),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.tileAll),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.signal,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
    );
  }
}
