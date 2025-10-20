import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

/// Extension to easily access AppLocalizations from BuildContext
extension LocalizationExtension on BuildContext {
  /// Get the current AppLocalizations instance
  ///
  /// Usage:
  /// ```dart
  /// Text(context.l10n.skip)
  /// ```
  AppLocalizations get l10n => AppLocalizations.of(this);
}
