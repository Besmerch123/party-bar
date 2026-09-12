import 'package:flutter/material.dart';
import 'package:party_bar/models/shared_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing the current locale throughout the app
///
/// Usage:
/// ```dart
/// // In main.dart, wrap your app:
/// ChangeNotifierProvider(
///   create: (_) => LocaleProvider()..initialize(),
///   child: MyApp(),
/// )
///
/// // In any widget:
/// final locale = context.watch<LocaleProvider>().currentLocale;
/// final cocktail = await repo.getCocktail(id, locale: locale);
/// ```
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _followSystemKey = 'app_locale_follow_system';

  SupportedLocale _currentLocale = SupportedLocale.en;
  bool _isInitialized = false;
  bool _followSystem = true;

  /// Get the current locale
  SupportedLocale get currentLocale => _currentLocale;

  /// Check if the provider has been initialized
  bool get isInitialized => _isInitialized;

  /// Flow 09 · screen 04 — "Follow my phone". True until someone picks a
  /// language by hand; picking one by hand is the only thing that turns it
  /// off, and flipping it back on is the only thing that turns it on again.
  bool get followsSystem => _followSystem;

  /// Get the current locale as a Flutter Locale
  Locale get locale {
    switch (_currentLocale) {
      case SupportedLocale.en:
        return const Locale('en');
      case SupportedLocale.uk:
        return const Locale('uk');
    }
  }

  /// Initialize the provider by loading the saved locale
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString(_localeKey);

    if (savedLocaleCode != null) {
      _currentLocale = _parseSupportedLocale(savedLocaleCode);
    }
    // Nobody has ever picked one by hand until [_localeKey] exists — after
    // that, the flag is whatever was last saved for it.
    _followSystem = prefs.getBool(_followSystemKey) ?? savedLocaleCode == null;

    _isInitialized = true;
    notifyListeners();
  }

  /// Set the current locale and persist it. A manual pick — the only thing
  /// that turns [followsSystem] off.
  Future<void> setLocale(SupportedLocale locale) async {
    _followSystem = false;
    await _applyLocale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followSystemKey, false);
  }

  /// Flow 09 · screen 04's toggle. Turning it on immediately adopts
  /// [deviceLocale]; turning it off just stops watching for the next one —
  /// the language already showing stays exactly as it is.
  Future<void> setFollowSystem(bool value, {required Locale deviceLocale}) async {
    if (_followSystem == value) return;
    _followSystem = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followSystemKey, value);

    if (value) {
      await _applyLocale(_parseSupportedLocale(deviceLocale.languageCode));
    } else {
      notifyListeners();
    }
  }

  Future<void> _applyLocale(SupportedLocale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _localeCodeString(locale));
    }

    notifyListeners();
  }

  /// Convert SupportedLocale to string
  String _localeCodeString(SupportedLocale locale) {
    switch (locale) {
      case SupportedLocale.en:
        return 'en';
      case SupportedLocale.uk:
        return 'uk';
    }
  }

  /// Parse string to SupportedLocale
  SupportedLocale _parseSupportedLocale(String code) {
    switch (code) {
      case 'uk':
        return SupportedLocale.uk;
      case 'en':
      default:
        return SupportedLocale.en;
    }
  }

}
