import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/models/onboarding.dart';
import 'package:party_bar/providers/onboarding_provider.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/onboarding/bottles_step.dart';
import 'package:party_bar/widgets/onboarding/onboarding_chrome.dart';
import 'package:party_bar/widgets/onboarding/onboarding_step.dart';
import 'package:party_bar/widgets/onboarding/value_bar_step.dart';
import 'package:party_bar/widgets/onboarding/value_orders_step.dart';
import 'package:party_bar/widgets/onboarding/vibe_step.dart';

/// The drawn size, plus a deliberately cramped phone the flow must survive.
const _sizes = <String, Size>{
  'iPhone 14 Pro': Size(390, 844),
  'small phone': Size(320, 568),
};

void main() {
  late OnboardingProvider provider;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    provider = OnboardingProvider();
    await provider.initialize();
  });

  Future<void> pumpStep(WidgetTester tester, Widget step, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<OnboardingProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('uk')],
          home: Scaffold(body: step),
        ),
      ),
    );
    await tester.pump();
  }

  const nav = OnboardingStepNav(
    stepIndex: 0,
    stepCount: 4,
    onNext: _noop,
    onBack: _noop,
    onSkip: _noop,
  );

  final steps = <String, Widget>{
    '02 value: your bar': const ValueBarStep(nav: nav),
    '03 value: they order': const ValueOrdersStep(nav: nav),
    '04 pick a vibe': const VibeStep(nav: nav),
    '05 stock five bottles': const BottlesStep(nav: nav),
  };

  for (final MapEntry(key: stepName, value: step) in steps.entries) {
    for (final MapEntry(key: deviceName, value: size) in _sizes.entries) {
      testWidgets('$stepName lays out on a $deviceName', (tester) async {
        await pumpStep(tester, step, size);
        expect(tester.takeException(), isNull);
      });
    }
  }

  // A loose Stack sizes itself to its widest non-positioned child, which
  // once left the hero stopping halfway across the screen.
  testWidgets('heroes reach both screen edges', (tester) async {
    const width = 390.0;

    for (final stepName in ['02 value: your bar', '03 value: they order']) {
      await pumpStep(tester, steps[stepName]!, const Size(width, 844));

      final hero = find.descendant(
        of: find.byType(OnboardingHero),
        matching: find.byType(Image),
      );
      expect(hero, findsOneWidget, reason: stepName);
      expect(tester.getSize(hero).width, width, reason: stepName);
    }
  });

  testWidgets('vibes are optional and toggle', (tester) async {
    await pumpStep(tester, steps['04 pick a vibe']!, _sizes['iPhone 14 Pro']!);

    expect(provider.vibes, isEmpty);

    await tester.tap(find.text('Sharp & citrus'));
    await tester.pumpAndSettle();

    expect(provider.isVibeSelected(DrinkVibe.sharpCitrus), isTrue);

    await tester.tap(find.text('Sharp & citrus'));
    await tester.pumpAndSettle();

    expect(provider.vibes, isEmpty);
  });

  testWidgets('stocking a bottle moves the pourable count', (tester) async {
    await pumpStep(
      tester,
      steps['05 stock five bottles']!,
      _sizes['iPhone 14 Pro']!,
    );

    expect(find.text('0 of 5 added'), findsOneWidget);
    expect(find.text('0 drinks unlocked'), findsOneWidget);

    await tester.tap(find.text('Gin'));
    await tester.pumpAndSettle();

    expect(provider.isBottleSelected('gin'), isTrue);
    expect(find.text('1 of 5 added'), findsOneWidget);
    expect(find.text('6 drinks unlocked'), findsOneWidget);
  });

  testWidgets('the shelf the flow is drawn at pours what it promises', (
    tester,
  ) async {
    for (final id in ['gin', 'vodka', 'tonic']) {
      await provider.toggleBottle(id);
    }

    // Flow 01 promises "you can pour 14" off gin, vodka and tonic, and that
    // one lime unlocks eleven more. Those two numbers are the whole pitch.
    expect(provider.pourableCount, 14);
    expect(provider.bestUnlock?.id, 'lime');
    expect(provider.bestUnlock?.unlocks, 11);
  });

  testWidgets('search narrows the shelf', (tester) async {
    await pumpStep(
      tester,
      steps['05 stock five bottles']!,
      _sizes['iPhone 14 Pro']!,
    );

    await tester.enterText(find.byType(TextField), 'rum');
    await tester.pumpAndSettle();

    expect(find.text('White rum'), findsOneWidget);
    expect(find.text('Gin'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('Nothing matched that search.'), findsOneWidget);
  });

  testWidgets('choices survive a restart', (tester) async {
    await provider.toggleVibe(DrinkVibe.darkStirred);
    await provider.toggleBottle('lime');

    final restarted = OnboardingProvider();
    await restarted.initialize();

    expect(restarted.isVibeSelected(DrinkVibe.darkStirred), isTrue);
    expect(restarted.isBottleSelected('lime'), isTrue);
  });
}

void _noop() {}
