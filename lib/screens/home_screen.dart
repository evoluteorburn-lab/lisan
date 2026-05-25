import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lisan'),
        backgroundColor: const Color(0xFF2D5A4A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App logo/icon
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2D5A4A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'لسان',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A4A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Welcome text
            Text(
              'Добро пожаловать в Lisan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'AI-переводчик с режимом обучения',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Mode selection
            _buildModeCard(
              context,
              title: 'Быстрый перевод',
              subtitle: 'Говорите — и мгновенно получайте перевод',
              icon: Icons.mic,
              color: const Color(0xFF2D5A4A),
              onTap: () => Navigator.pushNamed(context, '/translate'),
            ),
            const SizedBox(height: 16),
            _buildModeCard(
              context,
              title: 'Режим обучения',
              subtitle: 'Перевод + объяснение грамматики и контекста',
              icon: Icons.school,
              color: const Color(0xFF4A7C6F),
              onTap: () => Navigator.pushNamed(context, '/learn'),
            ),
            const SizedBox(height: 16),
            _buildModeCard(
              context,
              title: 'Мои фразы',
              subtitle: 'История переводов и избранное',
              icon: Icons.bookmark,
              color: const Color(0xFF6B9B8F),
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
            const SizedBox(height: 16),
            _buildModeCard(
              context,
              title: 'Готовые наборы',
              subtitle: 'Популярные фразы по ситуациям',
              icon: Icons.format_list_bulleted,
              color: const Color(0xFF8BB5AB),
              onTap: () => Navigator.pushNamed(context, '/phrase-sets'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
