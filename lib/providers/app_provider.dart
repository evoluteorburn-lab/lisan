import 'package:flutter/foundation.dart';

class AppProvider extends ChangeNotifier {
  // Language settings
  String _sourceLanguage = 'RU';
  String _targetLanguage = 'AR';
  
  // Mode: 'quick' or 'learn'
  String _currentMode = 'quick';
  
  // Translation state
  bool _isTranslating = false;
  String _lastOriginalText = '';
  String _lastTranslatedText = '';
  String _lastExplanation = '';
  String? _lastAudioPath;
  
  // History
  List<Map<String, dynamic>> _history = [];
  
  // Getters
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get currentMode => _currentMode;
  bool get isTranslating => _isTranslating;
  String get lastOriginalText => _lastOriginalText;
  String get lastTranslatedText => _lastTranslatedText;
  String get lastExplanation => _lastExplanation;
  String? get lastAudioPath => _lastAudioPath;
  List<Map<String, dynamic>> get history => _history;
  
  // Setters
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
  
  // History management
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
  
  // Swap languages
  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }
}
