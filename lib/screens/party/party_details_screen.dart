import 'package:flutter/material.dart';

class PartyDetailsScreen extends StatelessWidget {
  final String partyId;

  const PartyDetailsScreen({super.key, required this.partyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Details')),
      body: Center(
        child: Text(
          'Party Details for ID: $partyId\\nComing Soon!',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
