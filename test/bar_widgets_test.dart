import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/theme/theme.dart';
import 'package:party_bar/widgets/bar/bar_row.dart';

import 'support/harness.dart';

/// Flow 04's row is the one widget every My bar screen is built from, so it
/// has to survive the same two things that break any repeated layout: a
/// narrow phone, and someone who has turned their text up. These tests are
/// deliberately plain widgets with hand-fed strings — no [BarProvider], no
/// catalogue — so they keep passing while the models and provider are still
/// being built out from under them.

const _sizes = testSizes;

const _textScales = standardTextScales;

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pump(WidgetTester tester, Widget child, Size size, double textScale) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('uk')],
        builder: (context, widget) => MediaQuery.withClampedTextScaling(
          minScaleFactor: textScale,
          maxScaleFactor: textScale,
          child: widget!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  final rows = <String, Widget>{
    'image thumb': BarRow(
      leading: const BarThumb(
        image: 'assets/images/onboarding/gin.jpg',
        icon: Icons.liquor,
      ),
      title: 'London dry gin',
      subtitle: 'Bombay Sapphire · in 24 of your drinks',
      trailing: const BarActionCircle(
        icon: Icons.check,
        tone: BarActionTone.ready,
        semanticsLabel: 'On the shelf',
      ),
    ),
    'icon thumb, neutral trailing': BarRow(
      leading: const BarThumb(icon: Icons.liquor),
      title: 'Vodka',
      subtitle: 'In 38 drinks',
      trailing: const BarActionCircle(
        icon: Icons.add,
        semanticsLabel: 'Add to my bar',
      ),
    ),
    'checked thumb, ready trailing': BarRow(
      leading: const BarThumb(icon: Icons.check, checked: true),
      title: 'White rum',
      subtitle: 'On your shelf',
      subtitleColor: AppColors.ready,
      trailing: const BarActionCircle(
        icon: Icons.check,
        tone: BarActionTone.ready,
        semanticsLabel: 'On the shelf',
      ),
    ),
    'primary trailing': BarRow(
      leading: const BarThumb(icon: Icons.wine_bar),
      title: 'Cointreau',
      subtitle: 'Orange liqueur · in 22 drinks',
      trailing: const BarActionCircle(
        icon: Icons.add,
        tone: BarActionTone.primary,
        semanticsLabel: 'Add to my bar',
      ),
    ),
    'dim trailing': BarRow(
      leading: const BarThumb(
        icon: Icons.eco,
        tone: BarThumbTone.low,
      ),
      title: 'Lime',
      subtitle: 'Blocks 6 drinks · on your list',
      subtitleColor: AppColors.low,
      trailing: const BarActionCircle(
        icon: Icons.check,
        tone: BarActionTone.dim,
        semanticsLabel: 'Put lime back on the shelf',
      ),
    ),
    'low trailing, pill action': BarRow(
      leading: const BarThumb(icon: Icons.local_florist, tone: BarThumbTone.low),
      title: 'Mint',
      subtitle: 'Blocks 2 drinks',
      subtitleColor: AppColors.low,
      trailing: BarPillAction(label: 'Add to list', onTap: () {}),
    ),
    'highlighted titleSpan': BarRow(
      leading: const BarThumb(icon: Icons.wine_bar),
      title: 'Cointreau',
      titleSpan: const TextSpan(
        children: [
          TextSpan(
            text: 'Cointr',
            style: TextStyle(color: AppColors.signalLight),
          ),
          TextSpan(text: 'eau'),
        ],
      ),
      subtitle: 'Orange liqueur · in 22 drinks',
      trailing: const BarActionCircle(
        icon: Icons.add,
        tone: BarActionTone.primary,
        semanticsLabel: 'Add to my bar',
      ),
    ),
    'long title, long subtitle': BarRow(
      leading: const BarThumb(icon: Icons.wine_bar),
      title:
          'A Considerably Longer Bottle Name That Keeps Going And Going And Going',
      subtitle:
          'This subtitle also runs on for a very long while, longer than any row was ever meant to hold on one line',
      trailing: const BarActionCircle(
        icon: Icons.add,
        semanticsLabel: 'Add to my bar',
      ),
    ),
    'row inside a sheet, outline': BarRow(
      leading: const BarThumb(icon: Icons.liquor),
      title: 'London dry gin',
      background: AppColors.row,
      outline: AppColors.signal,
    ),
    'group header with action': const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: BarGroupHeader(
        label: 'Ran out · 3',
        color: AppColors.low,
        actionLabel: 'Add all to list',
        onAction: _noop,
      ),
    ),
    'group header, no action': const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: BarGroupHeader(label: 'Spirits & liqueurs · 9'),
    ),
  };

  for (final MapEntry(key: name, value: widget) in rows.entries) {
    for (final MapEntry(key: device, value: size) in _sizes.entries) {
      for (final scale in _textScales) {
        testWidgets('$name survives a $device at ${scale}x text', (
          tester,
        ) async {
          await pump(tester, widget, size, scale);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('a checked thumb shows the green check regardless of icon', (
    tester,
  ) async {
    await pump(
      tester,
      const BarThumb(icon: Icons.liquor, checked: true),
      _sizes.values.first,
      1.0,
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.liquor), findsNothing);
  });

  testWidgets('a highlighted titleSpan renders both spans', (tester) async {
    await pump(tester, rows['highlighted titleSpan']!, _sizes.values.first, 1.0);

    expect(find.textContaining('Cointreau'), findsOneWidget);
  });

  testWidgets('a long title still ellipsizes on one line', (tester) async {
    await pump(
      tester,
      rows['long title, long subtitle']!,
      const Size(320, 568),
      1.5,
    );

    final titleFinder = find.textContaining('A Considerably Longer Bottle Name');
    expect(titleFinder, findsOneWidget);
    final titleWidget = tester.widget<Text>(titleFinder);
    expect(titleWidget.maxLines, 1);
    expect(titleWidget.overflow, TextOverflow.ellipsis);
  });

  testWidgets('the pill action holds a 44pt-tall hit area', (tester) async {
    await pump(
      tester,
      rows['low trailing, pill action']!,
      _sizes.values.first,
      1.0,
    );

    final pillSize = tester.getSize(find.byType(BarPillAction));
    expect(pillSize.height, greaterThanOrEqualTo(44));
  });

  testWidgets('a trailing action circle is a full 44x44 tap target', (
    tester,
  ) async {
    await pump(
      tester,
      rows['icon thumb, neutral trailing']!,
      _sizes.values.first,
      1.0,
    );

    final circleSize = tester.getSize(find.byType(BarActionCircle));
    expect(circleSize.width, greaterThanOrEqualTo(44));
    expect(circleSize.height, greaterThanOrEqualTo(44));
  });
}

void _noop() {}
