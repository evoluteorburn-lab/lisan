import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        title: const Text('Обучение'),
        backgroundColor: const Color(0xFF1B4332),
      ),
      body: const Center(
        child: Text(
          'Режим обучения',
          style: TextStyle(color: Color(0xFFF5F5DC)),
        ),
      ),
    );
  }
}
