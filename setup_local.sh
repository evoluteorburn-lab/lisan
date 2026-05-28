#!/bin/bash

# Quick setup script for Lisan project
# Run this on your local machine

set -e

echo "================================"
echo "LISAN PROJECT SETUP"
echo "================================"

# Create project directory
PROJECT_DIR="$HOME/lisan"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "📁 Created directory: $PROJECT_DIR"

# Create directory structure
mkdir -p lib/{screens,services,providers}
mkdir -p .github/workflows
mkdir -p assets

echo "📂 Directory structure created"

# Create pubspec.yaml
cat > pubspec.yaml << 'EOF'
name: lisan
description: AI Translator with Learning Mode
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  provider: ^6.1.1
  flutter_dotenv: ^5.1.0
  record: ^5.0.4
  audioplayers: ^5.2.1
  path_provider: ^2.1.2
  permission_handler: ^11.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/.env
EOF

echo "✅ pubspec.yaml created"

# Create .env.example
cat > .env.example << 'EOF'
DEEPL_API_KEY=your_deepl_key_here
DEEPSEEK_API_KEY=your_deepseek_key_here
ELEVENLABS_API_KEY=your_elevenlabs_key_here
OPENAI_API_KEY=your_openai_key_here
EOF

echo "✅ .env.example created"

# Create main.dart
cat > lib/main.dart << 'EOF'
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D5A4A),
            primary: const Color(0xFF2D5A4A),
          ),
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
EOF

echo "✅ lib/main.dart created"

# Create app_provider.dart
cat > lib/providers/app_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';

class AppProvider extends ChangeNotifier {
  String _sourceLanguage = 'RU';
  String _targetLanguage = 'AR';
  String _currentMode = 'quick';
  bool _isTranslating = false;
  String _lastOriginalText = '';
  String _lastTranslatedText = '';
  String _lastExplanation = '';
  String? _lastAudioPath;
  List<Map<String, dynamic>> _history = [];

  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get currentMode => _currentMode;
  bool get isTranslating => _isTranslating;
  String get lastOriginalText => _lastOriginalText;
  String get lastTranslatedText => _lastTranslatedText;
  String get lastExplanation => _lastExplanation;
  String? get lastAudioPath => _lastAudioPath;
  List<Map<String, dynamic>> get history => _history;

  void setSourceLanguage(String lang) {
    _sourceLanguage = lang;
    notifyListeners();
  }

  void setTargetLanguage(String lang) {
    _targetLanguage = lang;
    notifyListeners();
  }

  void setMode(String mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void setTranslating(bool value) {
    _isTranslating = value;
    notifyListeners();
  }

  void setLastTranslation({
    required String original,
    required String translated,
    String explanation = '',
    String? audioPath,
  }) {
    _lastOriginalText = original;
    _lastTranslatedText = translated;
    _lastExplanation = explanation;
    _lastAudioPath = audioPath;
    notifyListeners();
  }

  void addToHistory({
    required String original,
    required String translated,
    String explanation = '',
    String? audioPath,
  }) {
    _history.insert(0, {
      'original': original,
      'translated': translated,
      'explanation': explanation,
      'audioPath': audioPath,
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      notifyListeners();
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }
}
EOF

echo "✅ lib/providers/app_provider.dart created"

echo ""
echo "================================"
echo "SETUP COMPLETE!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. Copy your API keys to assets/.env"
echo "3. flutter pub get"
echo "4. flutter build apk --release"
echo ""
echo "Or use Docker:"
echo "   ./build_docker.sh"
echo ""
echo "📁 Project location: $PROJECT_DIR"
