import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1B4332),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(const LisanApp());
}

class LisanApp extends StatelessWidget {
  const LisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lisan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1B4332),
        primaryColor: const Color(0xFFBFA15A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBFA15A),
          secondary: Color(0xFF2D5A4A),
          surface: Color(0xFF2D5A4A),
          background: Color(0xFF1B4332),
          error: Color(0xFFE74C3C),
          onPrimary: Color(0xFF1B4332),
          onSecondary: Color(0xFFF5F5DC),
          onSurface: Color(0xFFF5F5DC),
          onBackground: Color(0xFFF5F5DC),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B4332),
          foregroundColor: Color(0xFFF5F5DC),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF2D5A4A),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBFA15A),
            foregroundColor: const Color(0xFF1B4332),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
