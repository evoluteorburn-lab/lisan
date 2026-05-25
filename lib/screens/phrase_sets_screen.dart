import 'package:flutter/material.dart';

class PhraseSetsScreen extends StatelessWidget {
  const PhraseSetsScreen({super.key});

  final List<Map<String, dynamic>> _phraseSets = const [
    {
      'title': 'Приветствия',
      'icon': Icons.waving_hand,
      'phrases': [
        {'ru': 'Привет', 'ar': 'مرحباً'},
        {'ru': 'Доброе утро', 'ar': 'صباح الخير'},
        {'ru': 'Как дела?', 'ar': 'كيف حالك؟'},
      ],
    },
    {
      'title': 'В ресторане',
      'icon': Icons.restaurant,
      'phrases': [
        {'ru': 'Меню, пожалуйста', 'ar': 'القائمة، من فضلك'},
        {'ru': 'Счёт', 'ar': 'الحساب'},
        {'ru': 'Вкусно', 'ar': 'لذيذ'},
      ],
    },
    {
      'title': 'В магазине',
      'icon': Icons.shopping_cart,
      'phrases': [
        {'ru': 'Сколько стоит?', 'ar': 'كم السعر؟'},
        {'ru': 'Можно скидку?', 'ar': 'هل يمكن خصم؟'},
        {'ru': 'Я просто смотрю', 'ar': 'أنا فقط أتطلع'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Наборы фраз'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _phraseSets.length,
        itemBuilder: (context, index) {
          final set = _phraseSets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(set['icon'] as IconData, color: Colors.black),
              title: Text(
                set['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: (set['phrases'] as List<Map<String, String>>).map((phrase) {
                return ListTile(
                  title: Text(phrase['ru']!),
                  subtitle: Text(
                    phrase['ar']!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.black),
                    onPressed: () {
                      // TODO: Play audio
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
