import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  bool _isRecording = false;
  String? _lastRecordingPath;
  
  StreamSubscription? _amplitudeSubscription;
  final StreamController<double> _amplitudeController = StreamController<double>.broadcast();
  
  // Getters
  bool get isRecording => _isRecording;
  String? get lastRecordingPath => _lastRecordingPath;
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording
  Future<Map<String, dynamic>> startRecording() async {
    try {
      // Check permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return {
          'success': false,
          'error': 'Microphone permission denied',
        };
      }

      // Check if already recording
      if (_isRecording) {
        return {
          'success': false,
          'error': 'Already recording',
        };
      }

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/lisan_recording_$timestamp.m4a';

      // Configure recording
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      );

      // Start recording
      await _recorder.start(config, path: path);
      _isRecording = true;
      _lastRecordingPath = path;

      // Start amplitude monitoring
      _amplitudeSubscription?.cancel();
      _amplitudeSubscription = _recorder.onAmplitude(const Duration(milliseconds: 100)).listen((amp) {
        // Normalize amplitude to 0.0 - 1.0 range
        final normalized = (amp.current + 40) / 40; // Typical range: -40 to 0
        _amplitudeController.add(normalized.clamp(0.0, 1.0));
      });

      return {
        'success': true,
        'path': path,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Recording failed: $e',
      };
    }
  }

  /// Stop recording
  Future<Map<String, dynamic>> stopRecording() async {
    try {
      if (!_isRecording) {
        return {
          'success': false,
          'error': 'Not recording',
        };
      }

      // Stop amplitude monitoring
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      // Stop recording
      final path = await _recorder.stop();
      _isRecording = false;

      if (path == null) {
        return {
          'success': false,
          'error': 'Recording failed: no file generated',
        };
      }

      // Verify file exists
      final file = File(path);
      if (!file.existsSync()) {
        return {
          'success': false,
          'error': 'Recording file not found',
        };
      }

      final size = await file.length();

      return {
        'success': true,
        'path': path,
        'size': size,
      };
    } catch (e) {
      _isRecording = false;
      return {
        'success': false,
        'error': 'Stop recording failed: $e',
      };
    }
  }

  /// Cancel recording (delete file)
  Future<Map<String, dynamic>> cancelRecording() async {
    try {
      if (!_isRecording) {
        return {
          'success': false,
          'error': 'Not recording',
        };
      }

      // Stop amplitude monitoring
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      // Stop and delete
      final path = await _recorder.stop();
      _isRecording = false;

      if (path != null) {
        final file = File(path);
        if (file.existsSync()) {
          await file.delete();
        }
      }

      _lastRecordingPath = null;

      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Cancel recording failed: $e',
      };
    }
  }

  /// Play audio file
  Future<Map<String, dynamic>> playAudio(String path) async {
    try {
      // Check if file exists
      final file = File(path);
      if (!file.existsSync()) {
        return {
          'success': false,
          'error': 'Audio file not found',
        };
      }

      // Stop any current playback
      await _player.stop();

      // Play the file
      await _player.play(DeviceFileSource(path));

      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Playback failed: $e',
      };
    }
  }

  /// Play audio from bytes (for API responses)
  Future<Map<String, dynamic>> playAudioBytes(List<int> bytes) async {
    try {
      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/lisan_audio_$timestamp.mp3';
      
      final file = File(path);
      await file.writeAsBytes(bytes);

      // Play
      return await playAudio(path);
    } catch (e) {
      return {
        'success': false,
        'error': 'Playback from bytes failed: $e',
      };
    }
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    await _player.pause();
  }

  /// Resume playback
  Future<void> resumePlayback() async {
    await _player.resume();
  }

  /// Get playback state
  PlayerState get playbackState => _player.state;

  /// Stream of playback state changes
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  /// Stream of playback position
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  /// Stream of playback duration
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  /// Dispose resources
  Future<void> dispose() async {
    await _amplitudeSubscription?.cancel();
    await _amplitudeController.close();
    await _recorder.dispose();
    await _player.dispose();
  }
}