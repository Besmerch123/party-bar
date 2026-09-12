import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:party_bar/generated/l10n/app_localizations.dart';
import 'package:party_bar/providers/locale_provider.dart';
import 'package:party_bar/theme/theme.dart';

/// The two device sizes a layout test is drawn at: the size the app is
/// actually designed for, and a deliberately cramped phone the layout still
/// has to survive. Shared by every `*_layout_test.dart` (and a few flow
/// tests besides) that checks a screen holds together under a narrow phone.
const testSizes = <String, Size>{
  'iPhone 14 Pro': Size(390, 844),
  'small phone': Size(320, 568),
};

/// The bumped text scale layout tests hold themselves to, alongside the
/// default 1.0x. A narrow phone and someone who has turned their text up
/// are the two things that actually break a layout in the field — this is
/// the second of them.
const standardTextScales = <double>[1.0, 1.5];

/// The delegate set every screen in the app is localized through, in the
/// order `MaterialApp` expects them.
const standardLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Pumps [child] under nothing but a fresh [LocaleProvider] and the app's
/// own theme and localizations — no router, no other provider. For screens
/// that read only locale and take their data as plain constructor
/// arguments. `guest_round_layout_test.dart`, `join_party_layout_test.dart`
/// and `party_recap_layout_test.dart` had each drawn this pump
/// byte-for-byte identically; this is that pump, kept in one place.
Future<void> pumpLocaleAware(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: standardLocalizationsDelegates,
        supportedLocales: const [Locale('en'), Locale('uk')],
        builder: (context, widget) => MediaQuery.withClampedTextScaling(
          minScaleFactor: textScale,
          maxScaleFactor: textScale,
          child: widget!,
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
}
