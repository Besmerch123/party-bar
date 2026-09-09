import 'package:flutter/material.dart';

/// Palette for the "Nightfeed / Signal" design language.
///
/// One cool accent ([signal]) carries every primary action. [ready] and [low]
/// are status-only and must never be used decoratively.
abstract final class AppColors {
  // Surfaces
  static const ground = Color(0xFF0B0B0C);
  static const sheet = Color(0xFF131314);
  static const row = Color(0xFF1A1A1B);

  // Accent
  static const signal = Color(0xFF3B6CF6);
  static const signalLight = Color(0xFF9DB6FF);

  // Status
  static const ready = Color(0xFF35D07F);
  static const low = Color(0xFFF5A524);

  // Ink ramp: title / body / meta / hairline
  static const ink = Color(0xFFFFFFFF);
  static const inkBody = Color(0x99FFFFFF);
  static const inkMeta = Color(0x73FFFFFF);
  static const hairline = Color(0x1FFFFFFF);

  // Glass — only ever layered over photography.
  static const glass = Color(0x24FFFFFF);
  static const glassNav = Color(0x1AFFFFFF);
  static const glassStroke = Color(0x24FFFFFF);

  /// Flat translucent fills for use on [ground], where glass would look muddy.
  static const fillStrong = Color(0x1AFFFFFF);
  static const fillMuted = Color(0x14FFFFFF);
  static const fillSubtle = Color(0x0FFFFFFF);

  /// Tinted status backgrounds for chips and rows.
  static const signalWash = Color(0x333B6CF6);
  static const readyWash = Color(0x2935D07F);
  static const lowWash = Color(0x29F5A524);

  /// The one approved photo scrim. Keeps the top readable for glass chips and
  /// dissolves into [ground] so content can start without a hard edge.
  static const photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x8C0B0B0C),
      Color(0x000B0B0C),
      Color(0x1A0B0B0C),
      Color(0xFF0B0B0C),
    ],
    stops: [0.0, 0.32, 0.52, 1.0],
  );
}
