import 'package:flutter/material.dart';
import 'package:party_bar/models/shared_types.dart';

/// Provider for managing the current locale throughout the app
///
/// Usage:
/// ```dart
/// // In main.dart, wrap your app:
/// ChangeNotifierProvider(
///   create: (_) => LocaleProvider(),
///   child: MyApp(),
/// )
///
/// // In any widget:
/// final locale = context.watch<LocaleProvider>().currentLocale;
/// final cocktail = await repo.getCocktail(id, locale: locale);
/// ```
class LocaleProvider extends ChangeNotifier {
  SupportedLocale _currentLocale = SupportedLocale.en;

  /// Get the current locale
  SupportedLocale get currentLocale => _currentLocale;

  /// Get the current locale as a Flutter Locale
  Locale get locale {
    switch (_currentLocale) {
      case SupportedLocale.en:
        return const Locale('en');
      case SupportedLocale.uk:
        return const Locale('uk');
    }
  }

  /// Set the current locale
  void setLocale(SupportedLocale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  /// Set locale from Flutter Locale
  void setLocaleFromFlutter(Locale locale) {
    final supportedLocale = _parseSupportedLocale(locale.languageCode);
    setLocale(supportedLocale);
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

  /// Initialize from system locale
  void initializeFromSystem(BuildContext context) {
    final systemLocale = Localizations.localeOf(context);
    setLocaleFromFlutter(systemLocale);
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
