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

  SupportedLocale _currentLocale = SupportedLocale.en;
  bool _isInitialized = false;

  /// Get the current locale
  SupportedLocale get currentLocale => _currentLocale;

  /// Check if the provider has been initialized
  bool get isInitialized => _isInitialized;

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

    _isInitialized = true;
    notifyListeners();
  }

  /// Set the current locale and persist it
  Future<void> setLocale(SupportedLocale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _localeCodeString(locale));

      notifyListeners();
    }
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

  /// Set locale from Flutter Locale
  Future<void> setLocaleFromFlutter(Locale locale) async {
    final supportedLocale = _parseSupportedLocale(locale.languageCode);
    await setLocale(supportedLocale);
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

  /// Initialize from system locale (only if no saved preference exists)
  Future<void> initializeFromSystem(BuildContext context) async {
    // Only use system locale if we haven't saved a preference yet
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_localeKey)) {
      final systemLocale = Localizations.localeOf(context);
      await setLocaleFromFlutter(systemLocale);
    }
  }
}

/// Extension to easily get locale from BuildContext
extension LocaleContext on BuildContext {
  /// Get current locale from LocaleProvider
  /// Requires LocaleProvider to be provided above in the widget tree
  SupportedLocale get currentLocale {
    try {
      // If using Provider package
      final provider = this
          .dependOnInheritedWidgetOfExactType<LocaleProviderInheritedWidget>();
      return provider?.locale ?? SupportedLocale.en;
    } catch (e) {
      return SupportedLocale.en;
    }
  }
}

/// InheritedWidget wrapper for LocaleProvider
/// This allows accessing locale without Provider package
class LocaleProviderInheritedWidget extends InheritedWidget {
  final SupportedLocale locale;

  const LocaleProviderInheritedWidget({
    Key? key,
    required this.locale,
    required Widget child,
  }) : super(key: key, child: child);

  static LocaleProviderInheritedWidget? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleProviderInheritedWidget>();
  }

  @override
  bool updateShouldNotify(LocaleProviderInheritedWidget oldWidget) {
    return locale != oldWidget.locale;
  }
}
