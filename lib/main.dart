import 'package:flutter/material.dart';
import 'utils/app_router.dart';

void main() {
  runApp(const PartyBarApp());
}

class PartyBarApp extends StatelessWidget {
  const PartyBarApp({super.key});

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
      routerConfig: appRouter,
    );
  }
}
