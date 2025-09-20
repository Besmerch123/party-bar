import 'package:flutter/material.dart';

class CreateBarScreen extends StatelessWidget {
  const CreateBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Bar')),
      body: const Center(
        child: Text(
          'Create Bar Screen - Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
