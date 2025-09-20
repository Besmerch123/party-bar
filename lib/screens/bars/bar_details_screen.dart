import 'package:flutter/material.dart';

class BarDetailsScreen extends StatelessWidget {
  final String barId;

  const BarDetailsScreen({super.key, required this.barId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bar Details')),
      body: Center(
        child: Text(
          'Bar Details for ID: $barId\\nComing Soon!',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
