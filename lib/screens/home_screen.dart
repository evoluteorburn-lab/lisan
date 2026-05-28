import 'package:flutter/material.dart';
import 'translate_screen.dart';
import 'learn_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA15A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBFA15A).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ليسان',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBFA15A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lisan AI Переводчик',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF5F5DC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Говорите — слушайте — учитесь',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFF5F5DC).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildCard(
                context,
                icon: Icons.mic,
                title: 'Быстрый перевод',
                subtitle: 'Голос → Текст → Перевод → AI голос',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TranslateScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                icon: Icons.school,
                title: 'Режим обучения',
                subtitle: 'Перевод + объяснение грамматики',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearnScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                context,
                icon: Icons.history,
                title: 'История',
                subtitle: 'Сохранённые фразы и объяснения',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Рамадан Карим',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFBFA15A).withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D5A4A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBFA15A).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA15A).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: const Color(0xFFBFA15A),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F5DC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFF5F5DC).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFBFA15A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
