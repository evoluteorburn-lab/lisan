import 'package:flutter/material.dart';

/// Localization for Lisan app
/// Supports: Russian, English, Arabic
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'appName': 'Lisan',
      'appSubtitle': 'Голосовой переводчик',
      'tapToSpeak': 'Нажмите и говорите',
      'recording': 'Запись...',
      'history': 'История',
      'learning': 'Обучение',
      'selectLanguage': 'Выберите язык',
      'russian': 'Русский',
      'english': 'English',
      'arabic': 'العربية',
      'swapLanguages': 'Поменять языки',
      'translationResult': 'Перевод',
      'playAudio': 'Воспроизвести',
      'saveToChat': 'Сохранить в чат',
      'explain': 'Объяснить',
      'settings': 'Настройки',
      'language': 'Язык интерфейса',
      'about': 'О приложении',
    },
    'en': {
      'appName': 'Lisan',
      'appSubtitle': 'Voice Translator',
      'tapToSpeak': 'Tap and speak',
      'recording': 'Recording...',
      'history': 'History',
      'learning': 'Learning',
      'selectLanguage': 'Select Language',
      'russian': 'Russian',
      'english': 'English',
      'arabic': 'Arabic',
      'swapLanguages': 'Swap Languages',
      'translationResult': 'Translation',
      'playAudio': 'Play Audio',
      'saveToChat': 'Save to Chat',
      'explain': 'Explain',
      'settings': 'Settings',
      'language': 'Interface Language',
      'about': 'About',
    },
    'ar': {
      'appName': 'ليسان',
      'appSubtitle': 'المترجم الصوتي',
      'tapToSpeak': 'اضغط وتحدث',
      'recording': 'جاري التسجيل...',
      'history': 'السجل',
      'learning': 'التعلم',
      'selectLanguage': 'اختر اللغة',
      'russian': 'الروسية',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'swapLanguages': 'تبديل اللغات',
      'translationResult': 'الترجمة',
      'playAudio': 'تشغيل الصوت',
      'saveToChat': 'حفظ في المحادثة',
      'explain': 'شرح',
      'settings': 'الإعدادات',
      'language': 'لغة الواجهة',
      'about': 'حول التطبيق',
    },
  };

  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get appSubtitle => _localizedValues[locale.languageCode]!['appSubtitle']!;
  String get tapToSpeak => _localizedValues[locale.languageCode]!['tapToSpeak']!;
  String get recording => _localizedValues[locale.languageCode]!['recording']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get learning => _localizedValues[locale.languageCode]!['learning']!;
  String get selectLanguage => _localizedValues[locale.languageCode]!['selectLanguage']!;
  String get russian => _localizedValues[locale.languageCode]!['russian']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;
  String get swapLanguages => _localizedValues[locale.languageCode]!['swapLanguages']!;
  String get translationResult => _localizedValues[locale.languageCode]!['translationResult']!;
  String get playAudio => _localizedValues[locale.languageCode]!['playAudio']!;
  String get saveToChat => _localizedValues[locale.languageCode]!['saveToChat']!;
  String get explain => _localizedValues[locale.languageCode]!['explain']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ru', 'en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
