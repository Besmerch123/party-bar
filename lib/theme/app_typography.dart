import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type scale for the "Nightfeed / Signal" language.
///
/// Plus Jakarta Sans carries everything human. Space Mono is reserved for
/// quantities, codes and timers — never for sentences.
abstract final class AppTypography {
  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    double? letterSpacing,
    double? height,
    Color color = AppColors.ink,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );

  /// Screen-owning headline over a photo hero.
  static TextStyle get display =>
      _sans(size: 40, weight: FontWeight.w800, letterSpacing: -1.4, height: 1.0);

  static TextStyle get title => _sans(
    size: 36,
    weight: FontWeight.w800,
    letterSpacing: -1.26,
    height: 1.0,
  );

  /// Card and hero titles that sit inside content rather than owning a screen.
  static TextStyle get heading =>
      _sans(size: 26, weight: FontWeight.w800, letterSpacing: -0.91, height: 1.05);

  static TextStyle get section =>
      _sans(size: 15, weight: FontWeight.w700, letterSpacing: -0.15);

  static TextStyle get cardTitle =>
      _sans(size: 13.5, weight: FontWeight.w700, letterSpacing: -0.1);

  static TextStyle get body => _sans(
    size: 13.5,
    weight: FontWeight.w500,
    height: 1.55,
    color: AppColors.inkBody,
  );

  static TextStyle get meta => _sans(
    size: 12.5,
    weight: FontWeight.w500,
    height: 1.5,
    color: AppColors.inkMeta,
  );

  /// Always render the text uppercase alongside this style.
  static TextStyle get label =>
      _sans(size: 10.5, weight: FontWeight.w700, letterSpacing: 1.05);

  static TextStyle get buttonPrimary =>
      _sans(size: 15, weight: FontWeight.w800, letterSpacing: -0.15);

  static TextStyle get buttonSecondary =>
      _sans(size: 14, weight: FontWeight.w800, letterSpacing: -0.14);

  /// Quantities, codes, timers. Never sentences.
  static TextStyle get measure => GoogleFonts.spaceMono(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.inkBody,
  );

  /// Section eyebrows and monospaced overlines.
  static TextStyle get mono => GoogleFonts.spaceMono(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: AppColors.inkMeta,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    displayMedium: title,
    displaySmall: heading,
    headlineMedium: heading,
    titleLarge: section,
    titleMedium: cardTitle,
    titleSmall: cardTitle,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: meta,
    labelLarge: buttonSecondary,
    labelMedium: label,
    labelSmall: label,
  );
}
