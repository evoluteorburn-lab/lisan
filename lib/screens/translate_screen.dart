import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/translation_service.dart';
import '../services/audio_service.dart';
import '../theme/ramadan_theme.dart';
import '../widgets/night_sky_background.dart';
import '../widgets/gold_buttons.dart';
import '../widgets/lamp_button.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  bool _isRecording = false;
  bool _isTranslating = false;
  bool _showResult = false;
  String? _errorMessage;

  final TranslationService _translationService = TranslationService();
  final AudioService _audioService = AudioService();

  // Language display
  final Map<String, String> languageFlags = {
    'RU': '🇷🇺',
    'EN': '🇬🇧',
    'AR': '🇸🇦',
  };

  final Map<String, String> languageNames = {
    'RU': 'Русский',
    'EN': 'English',
    'AR': 'العربية',
  };

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: NightSkyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  l10n.appName,
                  style: RamadanTheme.headingStyle.copyWith(
                    fontSize: 32,
                    shadows: [
                      Shadow(
                        color: RamadanTheme.goldMatte.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.appSubtitle,
                  style: RamadanTheme.subheadingStyle,
                ),

                const SizedBox(height: 40),

                // Language selector
                _buildLanguageSelector(context, l10n),

                const SizedBox(height: 60),

                // Lamp recording button
                LampButton(
                  isRecording: _isRecording,
                  size: 160,
                  onTap: _isRecording ? _stopAndTranslate : _startRecording,
                ),

                const SizedBox(height: 24),

                // Recording hint
                Text(
                  _isRecording ? l10n.recording : l10n.tapToSpeak,
                  style: RamadanTheme.labelStyle.copyWith(
                    color: _isRecording
                        ? Colors.red.withOpacity(0.8)
                        : RamadanTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // Translation progress / result
                if (_isTranslating)
                  const Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(RamadanTheme.goldMatte),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Переводим...',
                        style: TextStyle(color: RamadanTheme.textSecondary),
                      ),
                    ],
                  ),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_showResult && !_isTranslating)
                  Expanded(child: _buildResult(context, l10n)),

                const Spacer(),

                // Bottom buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GoldButton(
                      text: l10n.history,
                      icon: Icons.history,
                      onTap: () => Navigator.pushNamed(context, '/history'),
                    ),
                    GoldButton(
                      text: l10n.learning,
                      icon: Icons.school,
                      onTap: () => Navigator.pushNamed(context, '/learn'),
                    ),
                    GoldButton(
                      text: l10n.settings,
                      icon: Icons.settings,
                      onTap: () => _showSettings(l10n),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l10n) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LanguageButton(
              language: languageNames[provider.sourceLanguage]!,
              flag: languageFlags[provider.sourceLanguage]!,
              isSelected: true,
              onTap: () => _showLanguagePicker(context, true),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: RamadanTheme.goldMatte.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.swap_horiz,
                  color: RamadanTheme.goldLight,
                  size: 28,
                ),
                onPressed: provider.swapLanguages,
              ),
            ),
            const SizedBox(width: 16),
            LanguageButton(
              language: languageNames[provider.targetLanguage]!,
              flag: languageFlags[provider.targetLanguage]!,
              isSelected: false,
              onTap: () => _showLanguagePicker(context, false),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startRecording() async {
    final result = await _audioService.startRecording();
    if (result['success']) {
      setState(() {
        _isRecording = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }

  Future<void> _stopAndTranslate() async {
    if (!_isRecording) return;

    final recordResult = await _audioService.stopRecording();
    if (!recordResult['success']) {
      setState(() {
        _isRecording = false;
        _errorMessage = recordResult['error'];
      });
      return;
    }

    setState(() {
      _isRecording = false;
      _isTranslating = true;
      _showResult = false;
      _errorMessage = null;
    });

    final transcribeResult = await _translationService.transcribeAudio(
      audioFilePath: recordResult['path'],
      language: 'ru',
    );

    if (!transcribeResult['success']) {
      setState(() {
        _isTranslating = false;
        _errorMessage = transcribeResult['error'] ?? 'Transcription failed';
      });
      return;
    }

    final text = transcribeResult['text'];
    await _performTranslation(text);
  }

  Future<void> _performTranslation(String text) async {
    try {
      final provider = context.read<AppProvider>();

      final result = await _translationService.fullPipeline(
        text: text,
        sourceLang: provider.sourceLanguage,
        targetLang: provider.targetLanguage,
        withExplanation: false,
        withVoice: true,
      );

      if (result['success']) {
        provider.setLastTranslation(
          original: result['original'],
          translated: result['translated'],
          audioPath: result['audio_path'],
        );

        if (result['audio_path'] != null) {
          await _audioService.playAudio(result['audio_path']);
        }

        setState(() {
          _isTranslating = false;
          _showResult = true;
        });
      } else {
        setState(() {
          _isTranslating = false;
          _errorMessage = result['error'] ?? 'Translation failed';
        });
      }
    } catch (e) {
      setState(() {
        _isTranslating = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Widget _buildResult(BuildContext context, AppLocalizations l10n) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: RamadanTheme.backgroundPrimary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: RamadanTheme.goldMatte.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextSection(
                label: provider.sourceLanguage == 'RU' ? 'Русский' : 'العربية',
                text: provider.lastOriginalText.isNotEmpty
                    ? provider.lastOriginalText
                    : 'Привет',
                isOriginal: true,
              ),
              const Divider(
                height: 32,
                color: RamadanTheme.goldMatte,
              ),
              _buildTextSection(
                label: provider.targetLanguage == 'AR' ? 'العربية' : 'Русский',
                text: provider.lastTranslatedText.isNotEmpty
                    ? provider.lastTranslatedText
                    : 'مرحباً',
                isOriginal: false,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.play_arrow,
                    label: l10n.playAudio,
                    onTap: () {
                      if (provider.lastAudioPath != null) {
                        _audioService.playAudio(provider.lastAudioPath!);
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.save,
                    label: l10n.saveToChat,
                    onTap: () {
                      provider.addToHistory(
                        original: provider.lastOriginalText,
                        translated: provider.lastTranslatedText,
                        audioPath: provider.lastAudioPath,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.saveToChat),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.help_outline,
                    label: l10n.explain,
                    onTap: () {
                      Navigator.pushNamed(context, '/learn');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextSection({
    required String label,
    required String text,
    required bool isOriginal,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: RamadanTheme.labelStyle,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isOriginal
                ? RamadanTheme.textPrimary
                : RamadanTheme.goldLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: RamadanTheme.goldMatte),
          const SizedBox(height: 4),
          Text(
            label,
            style: RamadanTheme.labelStyle,
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, bool isSource) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: RamadanTheme.backgroundPrimary,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguage,
                style: RamadanTheme.headingStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              _buildLangTile('RU', isSource),
              _buildLangTile('AR', isSource),
              _buildLangTile('EN', isSource),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangTile(String langCode, bool isSource) {
    final l10n = AppLocalizations.of(context)!;
    String label;
    switch (langCode) {
      case 'RU':
        label = l10n.russian;
        break;
      case 'EN':
        label = l10n.english;
        break;
      case 'AR':
        label = l10n.arabic;
        break;
      default:
        label = languageNames[langCode]!;
    }

    return ListTile(
      leading: Text(languageFlags[langCode]!, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: const TextStyle(color: RamadanTheme.textPrimary)),
      onTap: () {
        final provider = context.read<AppProvider>();
        if (isSource) {
          provider.setSourceLanguage(langCode);
        } else {
          provider.setTargetLanguage(langCode);
        }
        Navigator.pop(context);
      },
    );
  }

  void _showSettings(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: RamadanTheme.backgroundPrimary,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settings,
                style: RamadanTheme.headingStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.language, color: RamadanTheme.goldLight),
                title: Text(
                  l10n.language,
                  style: const TextStyle(color: RamadanTheme.textPrimary),
                ),
                onTap: () => _showLanguageSettings(l10n),
              ),
              ListTile(
                leading: const Icon(Icons.info, color: RamadanTheme.goldLight),
                title: Text(
                  l10n.about,
                  style: const TextStyle(color: RamadanTheme.textPrimary),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSettings(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: RamadanTheme.backgroundPrimary,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.language,
                style: RamadanTheme.headingStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              _buildAppLangTile('ru', '🇷🇺', l10n.russian),
              _buildAppLangTile('en', '🇬🇧', l10n.english),
              _buildAppLangTile('ar', '🇸🇦', l10n.arabic),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppLangTile(String langCode, String flag, String label) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final isSelected = currentLang == langCode;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: const TextStyle(color: RamadanTheme.textPrimary)),
      trailing: isSelected
          ? const Icon(Icons.check, color: RamadanTheme.goldLight)
          : null,
      onTap: () {
        _changeAppLanguage(langCode);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  void _changeAppLanguage(String langCode) {
    final app = context.findAncestorStateOfType<_LisanAppState>();
    if (app != null) {
      app.setLocale(Locale(langCode));
    }
  }
}
