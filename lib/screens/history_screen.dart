import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        title: const Text('История'),
        backgroundColor: const Color(0xFF1B4332),
      ),
      body: const Center(
        child: Text(
          'История переводов',
          style: TextStyle(color: Color(0xFFF5F5DC)),
        ),
      ),
    );
  }
}
