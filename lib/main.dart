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
import 'generated/l10n/app_localizations.dart';

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
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider()..initialize(),
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
            theme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.dark,
                primary: Colors.blue,
              ),
              useMaterial3: true,
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
