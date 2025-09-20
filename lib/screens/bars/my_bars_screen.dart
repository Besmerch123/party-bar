import 'package:flutter/material.dart';

class MyBarsScreen extends StatelessWidget {
  const MyBarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bars'), centerTitle: true),
      body: const Center(
        child: Text(
          'My Bars Screen - Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
