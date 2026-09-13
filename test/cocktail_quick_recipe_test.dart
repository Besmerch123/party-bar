import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/models.dart';
import 'package:party_bar/providers/bar_provider.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/providers/measure_unit_provider.dart';
import 'package:party_bar/screens/explore/cocktail_details_screen.dart';
import 'package:party_bar/theme/theme.dart';

/// The "Quick recipe" section added under the components list — amounts
/// only, no shelf status. Covers just the one thing worth locking down: a
/// stated measure actually renders next to its ingredient. Most of the
/// catalogue has no `measures` map yet, so a missing amount here is a data
/// gap, not a rendering bug — this guards against the rendering half.
void main() {
  setUp(() {
    // Without these, AppTheme reaches for fonts over the network and
    // MeasureUnitProvider has no mocked prefs to read — either one hangs
    // pumpAndSettle forever in a sandboxed test run instead of failing fast.
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  const delegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  final gin = Ingredient(id: 'gin', title: const {'en': 'Gin'}, category: IngredientCategory.spirit);
  final tonic = Ingredient(id: 'tonic', title: const {'en': 'Tonic water'}, category: IngredientCategory.mixer);

  final cocktail = Cocktail(
    id: 'gin-tonic',
    title: const {'en': 'Gin & Tonic'},
    description: const {'en': ''},
    image: '',
    categories: const [],
    ingredients: [gin, tonic],
    equipments: const [],
    measures: const {
      'gin': IngredientMeasure(amount: 50, unit: MeasureUnit.ml),
      'tonic': IngredientMeasure(amount: 1, unit: MeasureUnit.topUp),
    },
  );

  testWidgets('renders each ingredient\'s stated measure', (tester) async {
    final bar = BarProvider();
    await bar.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => MeasureUnitProvider()),
          ChangeNotifierProvider.value(value: bar),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: delegates,
          supportedLocales: const [Locale('en'), Locale('uk')],
          home: Scaffold(
            body: SingleChildScrollView(child: CocktailSheetContent(cocktail: cocktail)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quick recipe'), findsOneWidget);
    expect(find.text('50 ml'), findsOneWidget);
    expect(find.text('top up'), findsOneWidget);
  });
}
