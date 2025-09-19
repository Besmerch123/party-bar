import 'package:flutter/material.dart';

void main() {
  runApp(const PartyBarApp());
}

class PartyBarApp extends StatelessWidget {
  const PartyBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const PartyBarHome(),
    );
  }
}

class PartyBarHome extends StatelessWidget {
  const PartyBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Text(
          'PartyBar 1.1',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
