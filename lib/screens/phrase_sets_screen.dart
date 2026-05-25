import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class PhraseSetsScreen extends StatelessWidget {
  const PhraseSetsScreen({super.key});

  final List<Map<String, dynamic>> _phraseSets = const [
    {
      'title': 'Приветствия',
      'icon': Icons.waving_hand,
      'phrases': [
        {'ru': 'Привет', 'ar': 'مرحباً'},
        {'ru': 'Доброе утро', 'ar': 'صباح الخير'},
        {'ru': 'Добрый вечер', 'ar': 'مساء الخير'},
        {'ru': 'Как дела?', 'ar': 'كيف حالك؟'},
        {'ru': 'До свидания', 'ar': 'مع السلامة'},
      ],
    },
    {
      'title': 'В ресторане',
      'icon': Icons.restaurant,
      'phrases': [
        {'ru': 'Столик на двоих', 'ar': 'طاولة لشخصين'},
        {'ru': 'Меню, пожалуйста', 'ar': 'القائمة، من فضلك'},
        {'ru': 'Счёт, пожалуйста', 'ar': 'الحساب، من فضلك'},
        {'ru': 'Вкусно', 'ar': 'لذيذ'},
        {'ru': 'Я вегетарианец', 'ar': 'أنا نباتي'},
      ],
    },
    {
      'title': 'В магазине',
      'icon': Icons.shopping_cart,
      'phrases': [
        {'ru': 'Сколько стоит?', 'ar': 'كم سعر هذا؟'},
        {'ru': 'Можно скидку?', 'ar': 'هل يمكن الحصول على خصم؟'},
        {'ru': 'Я просто смотрю', 'ar': 'أنا فقط أتطلع'},
        {'ru': 'Где примерочная?', 'ar': 'أين غرفة القياس؟'},
        {'ru': 'Принимаете карту?', 'ar': 'هل تقبلون البطاقات؟'},
      ],
    },
    {
      'title': 'В отеле',
      'icon': Icons.hotel,
      'phrases': [
        {'ru': 'Номер на одного', 'ar': 'غرفة لشخص واحد'},
        {'ru': 'Ключ от номера', 'ar': 'مفتاح الغرفة'},
        {'ru': 'Завтрак включён?', 'ar': 'هل الإفطار مشمول؟'},
        {'ru': 'Где лифт?', 'ar': 'أين المصعد؟'},
        {'ru': 'Проблема с номером', 'ar': 'مشكلة في الغرفة'},
      ],
    },
    {
      'title': 'Экстренные',
      'icon': Icons.emergency,
      'phrases': [
        {'ru': 'Помогите!', 'ar': 'مساعدة!'},
        {'ru': 'Врач!', 'ar': 'طبيب!'},
        {'ru': 'Полиция!', 'ar': 'الشرطة!'},
        {'ru': 'Где больница?', 'ar': 'أين المستشفى؟'},
        {'ru': 'Я потерялся', 'ar': 'أنا تائه'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Готовые наборы'),
        backgroundColor: const Color(0xFF8BB5AB),
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
              leading: Icon(
                set['icon'] as IconData,
                color: const Color(0xFF2D5A4A),
              ),
              title: Text(
                set['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (set['phrases'] as List).length,
                  itemBuilder: (context, phraseIndex) {
                    final phrase = (set['phrases'] as List)[phraseIndex];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      title: Text(
                        phrase['ru'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        phrase['ar'],
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF2D5A4A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              // TODO: Play audio
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              // Add to favorites
                              final provider = context.read<AppProvider>();
                              provider.addToHistory(
                                original: phrase['ru'],
                                translated: phrase['ar'],
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Добавлено в избранное'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}