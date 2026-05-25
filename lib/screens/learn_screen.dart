import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/translation_service.dart';
import '../services/audio_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool _isRecording = false;
  bool _isLoading = false;
  bool _showResult = false;
  bool _showExplanation = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastResult;

  final TranslationService _translationService = TranslationService();
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Режим обучения'),
        backgroundColor: const Color(0xFF4A7C6F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Language selector
            _buildLanguageSelector(context),
            const SizedBox(height: 32),

            // Recording button
            _buildRecordingButton(),
            const SizedBox(height: 32),

            // Loading indicator
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A7C6F)),
                  ),
                  SizedBox(height: 16),
                  Text('Переводим и готовим объяснение...'),
                ],
              ),

            // Error message
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

            // Result with explanation
            if (_showResult && !_isLoading) _buildResultWithExplanation(context),
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
                icon: const Icon(Icons.swap_horiz),
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
      backgroundColor: const Color(0xFF4A7C6F).withOpacity(0.1),
    );
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopAndTranslate(),
      onTapCancel: () => _cancelRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 160 : 140,
        height: _isRecording ? 160 : 140,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : const Color(0xFF4A7C6F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? Colors.red : const Color(0xFF4A7C6F))
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          _isRecording ? Icons.mic : Icons.school,
          size: 56,
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

    // Stop recording
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
      _isLoading = true;
      _showResult = false;
      _showExplanation = false;
      _errorMessage = null;
    });

    // Transcribe audio
    final transcribeResult = await _translationService.transcribeAudio(
      audioFilePath: recordResult['path'],
      language: 'ru',
    );

    if (!transcribeResult['success']) {
      setState(() {
        _isLoading = false;
        _errorMessage = transcribeResult['error'] ?? 'Transcription failed';
      });
      return;
    }

    final text = transcribeResult['text'];

    // Translate with explanation
    await _performLearningTranslation(text);
  }

  Future<void> _cancelRecording() async {
    await _audioService.cancelRecording();
    setState(() => _isRecording = false);
  }

  Future<void> _performLearningTranslation(String text) async {
    try {
      final provider = context.read<AppProvider>();

      final result = await _translationService.fullPipeline(
        text: text,
        sourceLang: provider.sourceLanguage,
        targetLang: provider.targetLanguage,
        withExplanation: true,
        withVoice: true,
      );

      if (result['success']) {
        // Save to provider for history
        provider.setLastTranslation(
          original: result['original'],
          translated: result['translated'],
          explanation: result['explanation'] ?? '',
          audioPath: result['audio_path'],
        );

        // Play audio automatically
        if (result['audio_path'] != null) {
          await _audioService.playAudio(result['audio_path']);
        }

        setState(() {
          _lastResult = result;
          _isLoading = false;
          _showResult = true;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? 'Translation failed';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Widget _buildResultWithExplanation(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
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
                // Original text
                _buildTextSection(
                  label: 'Русский',
                  text: _lastResult?['original'] ?? 'Как дела?',
                  isOriginal: true,
                ),
                const Divider(height: 24),

                // Translated text
                _buildTextSection(
                  label: 'العربية',
                  text: _lastResult?['translated'] ?? 'كيف تسير الأمور؟',
                  isOriginal: false,
                ),
                const SizedBox(height: 16),

                // Show explanation button
                if (!_showExplanation)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _showExplanation = true);
                    },
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('Показать объяснение'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C6F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                // Explanation
                if (_showExplanation) _buildExplanation(),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.play_arrow,
                      label: 'Слушать',
                      onTap: () {
                        if (_lastResult?['audio_path'] != null) {
                          _audioService.playAudio(_lastResult!['audio_path']);
                        }
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.save,
                      label: 'Сохранить',
                      onTap: () {
                        final provider = context.read<AppProvider>();
                        provider.addToHistory(
                          original: _lastResult?['original'] ?? '',
                          translated: _lastResult?['translated'] ?? '',
                          explanation: _lastResult?['explanation'] ?? '',
                          audioPath: _lastResult?['audio_path'],
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
                      icon: Icons.favorite,
                      label: 'Избранное',
                      onTap: () {
                        // TODO: Add to favorites
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isOriginal ? Colors.black87 : const Color(0xFF4A7C6F),
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation() {
    final explanation = _lastResult?['explanation'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A7C6F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4A7C6F).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: const Color(0xFF4A7C6F),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Объяснение',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A7C6F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (explanation.isNotEmpty)
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            )
          else
            const Text(
              'Объяснение загружается...',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
        ],
      ),
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
          Icon(icon, size: 28, color: const Color(0xFF4A7C6F)),
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