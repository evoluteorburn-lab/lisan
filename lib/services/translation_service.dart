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

  // Base URLs
  static const String _deepLBase = 'https://api-free.deepl.com/v2';
  static const String _deepSeekBase = 'https://api.deepseek.com';
  static const String _elevenLabsBase = 'https://api.elevenlabs.io/v1';
  static const String _openAIBase = 'https://api.openai.com/v1';

  // Voice IDs
  static const String _arabicVoiceId = 'XB0fDUnXU5powFXDhCwa';
  static const String _russianVoiceId = 'N2lVS1wKimET73z01v';

  /// Full pipeline: transcribe → translate → explain (optional) → voice
  Future<Map<String, dynamic>> fullPipeline({
    required String text,
    required String sourceLang,
    required String targetLang,
    bool withExplanation = false,
    bool withVoice = true,
  }) async {
    try {
      // Step 1: Translate
      final translation = await translate(text, sourceLang, targetLang);
      if (!translation['success']) return translation;

      final translatedText = translation['translated'];

      // Step 2: Get explanation (if learn mode)
      String? explanation;
      if (withExplanation) {
        final explResult = await getExplanation(text, translatedText, sourceLang, targetLang);
        explanation = explResult['success'] ? explResult['explanation'] : null;
      }

      // Step 3: Generate voice (if needed)
      String? audioPath;
      if (withVoice) {
        final voiceResult = await textToSpeech(translatedText, targetLang);
        audioPath = voiceResult['success'] ? voiceResult['audio_path'] : null;
      }

      return {
        'success': true,
        'original': text,
        'translated': translatedText,
        'explanation': explanation,
        'audio_path': audioPath,
      };
    } catch (e) {
      return {'success': false, 'error': 'Pipeline error: $e'};
    }
  }

  /// Translate text using DeepL
  Future<Map<String, dynamic>> translate(String text, String sourceLang, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse('$_deepLBase/translate'),
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
          'translated': data['translations'][0]['text'],
        };
      } else {
        return {'success': false, 'error': 'DeepL error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Translation error: $e'};
    }
  }

  /// Get explanation from DeepSeek
  Future<Map<String, dynamic>> getExplanation(
    String original,
    String translated,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final prompt = '''Explain the translation from $sourceLang to $targetLang:
Original: $original
Translated: $translated

Provide:
1. Word-by-word breakdown
2. Grammar notes
3. Usage context
4. Pronunciation tips (transliteration)''';  

      final response = await http.post(
        Uri.parse('$_deepSeekBase/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_deepSeekKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': 'You are an Arabic language teacher. Explain translations clearly.'},
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
        return {'success': false, 'error': 'DeepSeek error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Explanation error: $e'};
    }
  }

  /// Text to speech using ElevenLabs
  Future<Map<String, dynamic>> textToSpeech(String text, String lang) async {
    try {
      final voiceId = lang == 'AR' ? _arabicVoiceId : _russianVoiceId;

      final response = await http.post(
        Uri.parse('$_elevenLabsBase/text-to-speech/$voiceId'),
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
        final audioFile = File('${tempDir.path}/lisan_tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(response.bodyBytes);

        return {
          'success': true,
          'audio_path': audioFile.path,
        };
      } else {
        return {'success': false, 'error': 'ElevenLabs error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'TTS error: $e'};
    }
  }

  /// Transcribe audio using OpenAI Whisper
  Future<Map<String, dynamic>> transcribeAudio({
    required String audioFilePath,
    String language = 'ru',
  }) async {
    try {
      final file = File(audioFilePath);
      if (!file.existsSync()) {
        return {'success': false, 'error': 'Audio file not found'};
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_openAIBase/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $_openAIKey';
      request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = language;

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return {
          'success': true,
          'text': data['text'],
        };
      } else {
        return {'success': false, 'error': 'Whisper error: ${response.statusCode} - $responseData'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Transcription error: $e'};
    }
  }
}
