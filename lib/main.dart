import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'utils/app_router.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart' show AuthenticationProvider;
import 'providers/measure_unit_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/bar_provider.dart';
import 'providers/explore_provider.dart';
import 'generated/l10n/app_localizations.dart';
import 'theme/theme.dart';

const _hasSeenWelcomeKey = 'has_seen_welcome';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore offline persistence (50MB cache)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 50 * 1024 * 1024, // 50MB
  );

  final prefs = await SharedPreferences.getInstance();
  final hasSeenWelcome = prefs.getBool(_hasSeenWelcomeKey) ?? false;

  if (!hasSeenWelcome) {
    await prefs.setBool(_hasSeenWelcomeKey, true);
  }

  runApp(PartyBarApp(showWelcome: !hasSeenWelcome));
}

class PartyBarApp extends StatelessWidget {
  PartyBarApp({super.key, required bool showWelcome})
    : _router = createAppRouter(showWelcome: showWelcome);

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => MeasureUnitProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthenticationProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider()..initialize(),
        ),

        // The bar is local first and an account claims it, rather than
        // owning it: attaching runs the same whether someone was already
        // signed in or just signed in this session.
        ChangeNotifierProxyProvider<AuthenticationProvider, BarProvider>(
          create: (_) => BarProvider()..initialize(),
          update: (_, auth, bar) {
            final provider = bar ?? (BarProvider()..initialize());
            provider.attachAccount(auth.user?.uid);
            return provider;
          },
        ),

        // Explore follows the shelf rather than owning it: the bar is the
        // source of truth, and a query re-derives whenever it changes.
        ChangeNotifierProxyProvider<BarProvider, ExploreProvider>(
          create: (_) => ExploreProvider()..initialize(),
          update: (_, bar, explore) {
            final provider = explore ?? (ExploreProvider()..initialize());
            provider.syncShelf(bar.shelf);
            return provider;
          },
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp.router(
            title: 'PartyBar',
            // Localization delegates
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('uk'), // Ukrainian
            ],
            locale: localeProvider.locale,
            theme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
