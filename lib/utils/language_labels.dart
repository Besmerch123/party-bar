import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n/app_localizations.dart';
import '../models/shared_types.dart';
import '../providers/locale_provider.dart';

/// A language's own name doesn't translate — "Українська" reads the same
/// whichever locale the rest of the app is in.
String languageDisplayName(SupportedLocale locale) => switch (locale) {
  SupportedLocale.en => 'English',
  SupportedLocale.uk => 'Українська',
};

/// The settings index's compact read of the language row.
String languageRowValue(BuildContext context, AppLocalizations l10n) {
  final locale = context.watch<LocaleProvider>();
  if (locale.followsSystem) return l10n.settingsLanguageFollowsPhone;
  return languageDisplayName(locale.currentLocale);
}
