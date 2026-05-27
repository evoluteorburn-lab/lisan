import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/translation_service.dart';
import '../services/audio_service.dart';

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

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Быстрый перевод'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildLanguageSelector(context),
            const SizedBox(height: 40),
            _buildRecordingButton(),
            const SizedBox(height: 40),
            if (_isTranslating)
              const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A4A)),
                  ),
                  SizedBox(height: 16),
                  Text('Переводим...'),
                ],
              ),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            if (_showResult && !_isTranslating) _buildResult(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLanguageChip(provider.sourceLanguage),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 32, size: 32, size: 32),
                onPressed: provider.swapLanguages,
              ),
              const SizedBox(width: 12),
              _buildLanguageChip(provider.targetLanguage),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageChip(String lang) {
    return Chip(
      label: Text(
        lang,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.black.withOpacity(0.1),
    );
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopAndTranslate(),
      onTapCancel: () => _cancelRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 180 : 160,
        height: _isRecording ? 180 : 160,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : const Color(0xFF2D5A4A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? Colors.red : const Color(0xFF2D5A4A))
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.mic : Icons.mic_none,
          size: 64,
          color: Colors.white,
        ),
      ),
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

  Future<void> _cancelRecording() async {
    await _audioService.cancelRecording();
    setState(() => _isRecording = false);
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

  Widget _buildResult(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                  const Divider(height: 32),
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
                        label: 'Слушать',
                        onTap: () {
                          if (provider.lastAudioPath != null) {
                            _audioService.playAudio(provider.lastAudioPath!);
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.save,
                        label: 'Сохранить',
                        onTap: () {
                          provider.addToHistory(
                            original: provider.lastOriginalText,
                            translated: provider.lastTranslatedText,
                            audioPath: provider.lastAudioPath,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Сохранено в историю'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.share,
                        label: 'Поделиться',
                        onTap: () {
                          // TODO: Share
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isOriginal ? Colors.black87 : const Color(0xFF2D5A4A),
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
          Icon(icon, size: 28, color: const Color(0xFF2D5A4A)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
