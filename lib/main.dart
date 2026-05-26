import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
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

class LisanApp extends StatefulWidget {
  const LisanApp({super.key});

  @override
  State<LisanApp> createState() => _LisanAppState();
}

class _LisanAppState extends State<LisanApp> {
  Locale _locale = const Locale('ru');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Lisan v1.0.2',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: const [
          Locale('ru'),
          Locale('en'),
          Locale('ar'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A0E21)),
          primaryColor: const Color(0xFF0A0E21),
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
