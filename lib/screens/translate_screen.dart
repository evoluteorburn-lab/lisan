import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/translation_service.dart';
import '../services/tts_service.dart';
import '../services/voice_service.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _sourceLang = 'ru';
  String _targetLang = 'ar';
  bool _isTranslating = false;

  final List<Map<String, String>> _languages = [
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية'},
  ];

  Future<void> _translate() async {
    if (_inputController.text.isEmpty) return;
    
    setState(() => _isTranslating = true);
    
    try {
      final result = await _translationService.translate(
        text: _inputController.text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );
      
      setState(() {
        _outputController.text = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка перевода: $e')),
      );
    }
  }

  Future<void> _speak() async {
    if (_outputController.text.isEmpty) return;
    await TTSService.speak(_outputController.text, _targetLang);
  }

  Future<void> _startVoiceInput() async {
    try {
      final text = await VoiceService.listen(_sourceLang);
      if (text.isNotEmpty) {
        _inputController.text = text;
        await _translate();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка голосового ввода: $e')),
      );
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      appBar: AppBar(
        title: const Text('Перевод'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: const Color(0xFFF5F5DC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangDropdown(_sourceLang, (val) => setState(() => _sourceLang = val!)),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Color(0xFFF5F5DC), size: 32),
                  onPressed: _swapLanguages,
                ),
                _buildLangDropdown(_targetLang, (val) => setState(() => _targetLang = val!)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFFF5F5DC)),
              decoration: InputDecoration(
                hintText: 'Введите текст...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTranslating ? null : _translate,
              icon: _isTranslating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.translate),
              label: Text(_isTranslating ? 'Перевод...' : 'ПЕРЕВЕСТИ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1B4332),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _outputController,
              maxLines: 4,
              readOnly: true,
              style: const TextStyle(color: Color(0xFFF5F5DC)),
              decoration: InputDecoration(
                hintText: 'Перевод...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildVoiceButton(
                  icon: Icons.mic,
                  label: 'Говорить',
                  onPressed: _startVoiceInput,
                ),
                _buildVoiceButton(
                  icon: Icons.volume_up,
                  label: 'Слушать',
                  onPressed: _speak,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      dropdownColor: const Color(0xFF1B4332),
      style: const TextStyle(color: Color(0xFFF5F5DC)),
      underline: Container(height: 2, color: const Color(0xFFD4AF37)),
      onChanged: onChanged,
      items: _languages.map((lang) {
        return DropdownMenuItem(
          value: lang['code'],
          child: Text(lang['name']!),
        );
      }).toList(),
    );
  }

  Widget _buildVoiceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4AF37),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF1B4332), size: 32),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Color(0xFFF5F5DC), fontSize: 12)),
      ],
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
