import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_router.dart';

const _hasSeenWelcomeKey = 'has_seen_welcome';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp.router(
      title: 'PartyBar',
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
  }
}
