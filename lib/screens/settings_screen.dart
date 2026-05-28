import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: const Color(0xFF1B4332),
      ),
      body: const Center(
        child: Text(
          'Настройки',
          style: TextStyle(color: Color(0xFFF5F5DC)),
        ),
      ),
    );
  }
}
