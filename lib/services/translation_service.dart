import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // API Keys from .env
  String get _deepLKey => dotenv.env['DEEPL_API_KEY'] ?? '';
  String get _deepSeekKey => dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  String get _elevenLabsKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  String get _openAIKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // API URLs
  static const String _deepLUrl = 'https://api-free.deepl.com/v2/translate';
  static const String _deepSeekUrl = 'https://api.deepseek.com/chat/completions';
  static const String _elevenLabsBaseUrl = 'https://api.elevenlabs.io/v1';
  static const String _whisperUrl = 'https://api.openai.com/v1/audio/transcriptions';

  /// Translate text using DeepL
  Future<Map<String, dynamic>> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_deepLUrl),
        headers: {
          'Authorization': 'DeepL-Auth-Key $_deepLKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': [text],
          'source_lang': sourceLang,
          'target_lang': targetLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'translated_text': data['translations'][0]['text'],
          'detected_source': data['translations'][0]['detected_source_language'],
        };
      } else {
        return {
          'success': false,
          'error': 'DeepL API error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Translation failed: $e',
      };
    }
  }

  /// Get explanation from DeepSeek
  Future<Map<String, dynamic>> getExplanation({
    required String originalText,
    required String translatedText,
    required String targetLang,
  }) async {
    try {
      final prompt = '''You are a language learning assistant. Explain the translation from Russian to $targetLang.

Original (Russian): $originalText
Translation ($targetLang): $translatedText

Provide:
1. Literal translation (word-by-word meaning)
2. Context and usage (when to use this phrase)
3. Alternative expressions (1-2 variations with dialect notes if applicable)
4. Cultural notes (if relevant)

Keep it concise but informative. Use Arabic script for Arabic examples.''';

      final response = await http.post(
        Uri.parse(_deepSeekUrl),
        headers: {
          'Authorization': 'Bearer $_deepSeekKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful language tutor specializing in Arabic and Russian.'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'explanation': data['choices'][0]['message']['content'],
        };
      } else {
        return {
          'success': false,
          'error': 'DeepSeek API error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Explanation failed: $e',
      };
    }
  }

  /// Convert text to speech using ElevenLabs
  Future<Map<String, dynamic>> textToSpeech({
    required String text,
    required String language,
  }) async {
    try {
      final voiceMap = {
        'AR': 'JBFqnCBsd6RMkjVDRZzb',
        'RU': 'N2lVS1wKimET73z01v',
        'EN': 'XB0fDUnXU5powFXDhCwa',
      };

      final voiceId = voiceMap[language] ?? voiceMap['AR']!;

      final response = await http.post(
        Uri.parse('$_elevenLabsBaseUrl/text-to-speech/$voiceId'),
        headers: {
          'xi-api-key': _elevenLabsKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.5,
          },
        }),
      );

      if (response.statusCode == 200) {
        // Save audio to temp file
        final tempDir = Directory.systemTemp;
        final audioFile = File('${tempDir.path}/lisan_tts_${language}_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(response.bodyBytes);

        return {
          'success': true,
          'audio_path': audioFile.path,
          'audio_bytes': response.bodyBytes,
        };
      } else {
        return {
          'success': false,
          'error': 'ElevenLabs API error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'TTS failed: $e',
      };
    }
  }

  /// Transcribe audio using Whisper (OpenAI)
  Future<Map<String, dynamic>> transcribeAudio({
    required String audioFilePath,
    String language = 'ru',
  }) async {
    try {
      final file = File(audioFilePath);
      if (!file.existsSync()) {
        return {
          'success': false,
          'error': 'Audio file not found',
        };
      }

      final request = http.MultipartRequest('POST', Uri.parse(_whisperUrl));
      request.headers['Authorization'] = 'Bearer $_openAIKey';
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = language;
      request.fields['response_format'] = 'json';
      request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return {
          'success': true,
          'text': data['text'],
          'language': data['language'] ?? language,
        };
      } else {
        return {
          'success': false,
          'error': 'Whisper API error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Transcription failed: $e',
      };
    }
  }

  /// Full pipeline: translate + explain + TTS
  Future<Map<String, dynamic>> fullPipeline({
    required String text,
    String sourceLang = 'RU',
    String targetLang = 'AR',
    bool withExplanation = true,
    bool withVoice = true,
  }) async {
    // Step 1: Translate
    final translation = await translate(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    if (!translation['success']) {
      return translation;
    }

    final translated = translation['translated_text'];
    final result = {
      'success': true,
      'original': text,
      'translated': translated,
    };

    // Step 2: Explain
    if (withExplanation) {
      final explanation = await getExplanation(
        originalText: text,
        translatedText: translated,
        targetLang: targetLang,
      );

      if (explanation['success']) {
        result['explanation'] = explanation['explanation'];
      }
    }

    // Step 3: Voice
    if (withVoice) {
      final tts = await textToSpeech(
        text: translated,
        language: targetLang,
      );

      if (tts['success']) {
        result['audio_path'] = tts['audio_path'];
        result['audio_bytes'] = tts['audio_bytes'];
      }
    }

    return result;
  }
}