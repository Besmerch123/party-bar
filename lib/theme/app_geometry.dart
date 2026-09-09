import 'package:flutter/material.dart';

/// Radii, spacing rhythm and motion for the "Nightfeed / Signal" language.
abstract final class AppRadius {
  static const tile = 18.0;
  static const card = 22.0;
  static const sheet = 28.0;
  static const pill = 999.0;

  static const tileAll = BorderRadius.all(Radius.circular(tile));
  static const cardAll = BorderRadius.all(Radius.circular(card));
  static const pillAll = BorderRadius.all(Radius.circular(pill));
  static const sheetTop = BorderRadius.vertical(top: Radius.circular(sheet));
}

/// Vertical rhythm steps. Prefer these over arbitrary gaps.
abstract final class AppSpacing {
  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 26.0;

  static const screenEdge = 22.0;
  static const cardInset = 18.0;

  static const screen = EdgeInsets.symmetric(horizontal: screenEdge);
  static const card = EdgeInsets.all(cardInset);
}

abstract final class AppSizes {
  /// Nothing tappable may be smaller than this.
  static const minTap = 44.0;

  static const buttonPrimary = 56.0;
  static const buttonSecondary = 54.0;
  static const buttonGhost = 52.0;

  static const navBar = 62.0;
  static const glassBlur = 12.0;
}

abstract final class AppMotion {
  static const sheet = Duration(milliseconds: 240);
  static const tap = Duration(milliseconds: 120);
  static const curve = Curves.easeOut;
}

/// The only shadow in the system — sheets rising over a held photo.
const kSheetShadow = BoxShadow(
  color: Color(0x80000000),
  offset: Offset(0, -22),
  blurRadius: 44,
);
