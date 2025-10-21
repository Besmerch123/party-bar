import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: const Center(
        child: Text(
          'Auth Screen - Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
