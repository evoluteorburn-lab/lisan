import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/translate_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/history_screen.dart';
import 'screens/phrase_sets_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(const LisanApp());
}

class LisanApp extends StatelessWidget {
  const LisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Lisan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D5A4A)),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/translate': (context) => const TranslateScreen(),
          '/learn': (context) => const LearnScreen(),
          '/history': (context) => const HistoryScreen(),
          '/phrase-sets': (context) => const PhraseSetsScreen(),
        },
      ),
    );
  }
}
