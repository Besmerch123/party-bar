# Localization Setup Guide

This Flutter app uses the official Flutter localization system with ARB (Application Resource Bundle) files.

`app_en.arb` and `app_uk.arb` currently carry 903 keys each, in identical
order, with no per-language gaps. Keys are only ever removed once nothing
references them: a key is reached exclusively as `l10n.<key>`,
`context.l10n.<key>`, or `AppLocalizations.of(context).<key>` (there is no
reflection to dispatch a key name built at runtime), so
`grep -rn '\.l10n\.\|l10n\.' lib test` for a key's exact name is the reliable
way to check whether it's still used before deleting it. A prune of 143
long-dead keys (orphaned by the email-auth lane, an old admin panel, and a
pre-redesign onboarding carousel, none of which ship anymore) took the
template from 1046 keys down to the current 903.

## 📁 Project Structure

```
lib/
├── l10n/                      # ARB translation files
│   ├── app_en.arb            # English translations
│   └── app_uk.arb            # Ukrainian translations
├── generated/
│   └── l10n/                 # Auto-generated localization code
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       └── app_localizations_uk.dart
├── providers/
│   └── locale_provider.dart  # Manages current locale state
├── models/
│   └── shared_types.dart     # I18nField for dynamic DB content
└── utils/
    └── localization_helper.dart  # Helper extensions
```

## 🎯 Two Types of Localization

This app supports **two types** of localized content:

### 1. **Static UI Labels** (ARB files)
For hardcoded strings in the app UI (buttons, titles, labels, etc.)

**Example:**
```dart
// Before
Text('Profile')

// After
import '../../generated/l10n/app_localizations.dart';

Text(AppLocalizations.of(context).profile)
// Or use the extension
Text(context.l10n.profile)
```

### 2. **Dynamic Database Content** (I18nField)
For data coming from Firebase/Firestore that contains translations

**Example:**
```dart
// In your model (e.g., Cocktail, Ingredient, Equipment)
class Ingredient {
  final I18nField title;  // { 'en': 'Vodka', 'uk': 'Горілка' }
  // ...
}

// In your widget
import 'package:party_bar/models/shared_types.dart';

Text(ingredient.title.translate(context))
```

## 🚀 Adding New Static Translations

### Step 1: Add to ARB files

**lib/l10n/app_en.arb:**
```json
{
  "myNewLabel": "My New Label",
  "@myNewLabel": {
    "description": "Description of where this is used"
  }
}
```

**lib/l10n/app_uk.arb:**
```json
{
  "myNewLabel": "Моя нова мітка"
}
```

### Step 2: Regenerate localization code

```bash
flutter gen-l10n
```

Or just run:
```bash
flutter run
```
(It auto-generates on build)

### Step 3: Use in your code

```dart
import '../../generated/l10n/app_localizations.dart';

// Method 1: Direct access
final l10n = AppLocalizations.of(context);
Text(l10n.myNewLabel)

// Method 2: Using extension (recommended)
import '../../utils/localization_helper.dart';
Text(context.l10n.myNewLabel)
```

## 🔧 ARB File Features

### Simple strings
```json
{
  "hello": "Hello",
  "@hello": {
    "description": "Greeting"
  }
}
```

### Strings with placeholders
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Personalized greeting",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
```

Usage:
```dart
Text(l10n.greeting('Alice'))
```

### Pluralization
```json
{
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Number of items",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

## 🌍 Switching Languages

The app uses `LocaleProvider` to manage the current locale:

```dart
// Get current locale
final locale = context.read<LocaleProvider>().currentLocale;

// Change locale
await context.read<LocaleProvider>().setLocale(SupportedLocale.uk);
```

The language switcher lives in Settings → Language
(`lib/screens/settings/language_screen.dart`), not on the profile screen — it
also drives the "Follow my phone" toggle (`LocaleProvider.setFollowSystem`),
which stays on until someone picks a language by hand.

## 📝 Best Practices

### 1. **Always provide descriptions**
```json
{
  "save": "Save",
  "@save": {
    "description": "Save button in the form"  // ✅ Good
  }
}
```

### 2. **Use meaningful keys**
```dart
"onboardingTitle1"  // ✅ Good
"text1"             // ❌ Bad
```

### 3. **Keep keys in English**
```json
"profile": "Профіль"     // ✅ Good (key is English)
"профіль": "Профіль"     // ❌ Bad (key is Ukrainian)
```

### 4. **Group related translations**
```json
{
  "onboardingTitle1": "...",
  "onboardingDescription1": "...",
  "onboardingTitle2": "...",
  "onboardingDescription2": "..."
}
```

### 5. **Don't localize proper nouns**
```json
{
  "appTitle": "PartyBar"  // Same in all languages
}
```

## 🔄 Combining Static & Dynamic Localizations

Sometimes you need both types in one widget:

```dart
import '../../generated/l10n/app_localizations.dart';
import '../../models/shared_types.dart';

class CocktailCard extends StatelessWidget {
  final Cocktail cocktail;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Column(
        children: [
          // Static label (from ARB)
          Text(l10n.ingredients),
          
          // Dynamic content (from DB)
          Text(cocktail.title.translate(context)),
          
          // Mix both
          Text('${l10n.ingredients}: ${cocktail.ingredientCount}'),
        ],
      ),
    );
  }
}
```

## 🛠️ Configuration Files

### l10n.yaml
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
output-dir: lib/generated/l10n
```

### pubspec.yaml
```yaml
flutter:
  generate: true  # Enables code generation
  
dependencies:
  flutter_localizations:
    sdk: flutter
```

## 📚 Examples in the Codebase

Check these files for working examples:

1. **lib/widgets/onboarding/bottles_step.dart** - Multiple translated strings with placeholders (`l10n.onboardingBottlesAdded(...)`, `l10n.bottleUnlocksMore(bottle.unlocks)`)
2. **lib/screens/settings/language_screen.dart** - A simple screen built entirely from `context.l10n`, including a placeholder call (`settingsLanguageFollowsPhoneCaption`)
3. **lib/widgets/explore/cocktail_cards.dart** - Mixing static ARB labels (`l10n.exploreMissingBadge(...)`) with dynamic DB content (`cocktail.title.translate(context)`)
4. **lib/providers/locale_provider.dart** - Locale management

## 🐛 Troubleshooting

### "Target of URI doesn't exist" error
Run:
```bash
flutter gen-l10n
```

### Translations not updating
1. Clean build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Generate l10n: `flutter gen-l10n`
4. Rebuild: `flutter run`

### Hot reload not picking up new translations
- Hot restart (not just hot reload) is required for ARB changes
- Or rebuild the app completely

## 🎓 Learn More

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Flutter Gen L10n](https://docs.flutter.dev/development/accessibility-and-localization/internationalization#adding-your-own-localized-messages)
