import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:provider/provider.dart';

/// Supported locales in the app
enum SupportedLocale { en, uk }

/// I18n field type that can contain translations for multiple locales
typedef I18nField = Map<String, String>;

/// Extension to easily get translated text from I18nField
extension I18nFieldExtension on I18nField {
  /// Get translation for the given locale, falling back to English if not found
  String translate(BuildContext context) {
    final locale = context.read<LocaleProvider>().currentLocale;
    final localeKey = locale.name;
    return this[localeKey] ?? this['en'] ?? entries.firstOrNull?.value ?? '';
  }

  /// Get translation for the current system locale
  String get translated {
    // You can inject a locale provider here or use a global locale
    // For now, defaulting to English
    return this['en'] ?? entries.firstOrNull?.value ?? '';
  }
}

/// I18n field type for arrays (e.g., list of strings in multiple languages)
typedef I18nArrayField = Map<String, List<String>>;

extension I18nArrayFieldExtension on I18nArrayField {
  /// Get translated array for the given locale, falling back to English if not found
  List<String> translate(BuildContext context) {
    final locale = context.read<LocaleProvider>().currentLocale;
    final localeKey = locale.name;
    return this[localeKey] ?? this['en'] ?? entries.firstOrNull?.value ?? [];
  }

  /// Get translated array for the current system locale
  List<String> get translated {
    // You can inject a locale provider here or use a global locale
    // For now, defaulting to English
    return this['en'] ?? entries.firstOrNull?.value ?? [];
  }
}

/// Base class for Firestore document transformers
abstract class FirestoreTransformer<TDocument, TEntity> {
  /// Convert Firestore document to domain entity
  TEntity fromDocument(TDocument document, String id, SupportedLocale locale);

  /// Convert domain entity to Firestore document (for writes)
  TDocument toDocument(TEntity entity);
}

/// Helper to convert Firestore Timestamp to DateTime
DateTime? timestampToDateTime(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is String) return DateTime.parse(timestamp);
  return null;
}

/// Helper to convert DateTime to Firestore Timestamp
Timestamp? dateTimeToTimestamp(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}
