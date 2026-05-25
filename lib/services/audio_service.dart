import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  String? _lastRecordingPath;

  /// Start recording audio
  Future<Map<String, dynamic>> startRecording() async {
    try {
      // Check permissions
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        return {
          'success': false,
          'error': 'Microphone permission denied',
        };
      }

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/lisan_recording_$timestamp.m4a';

      // Start recording
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacHe),
        path: path,
      );

      _isRecording = true;
      _lastRecordingPath = path;

      return {
        'success': true,
        'path': path,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Recording error: $e',
      };
    }
  }

  /// Stop recording and return file path
  Future<Map<String, dynamic>> stopRecording() async {
    try {
      if (!_isRecording) {
        return {
          'success': false,
          'error': 'Not recording',
        };
      }

      final path = await _recorder.stop();
      _isRecording = false;

      if (path == null) {
        return {
          'success': false,
          'error': 'No recording found',
        };
      }

      return {
        'success': true,
        'path': path,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Stop recording error: $e',
      };
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
    }
  }

  /// Play audio file
  Future<Map<String, dynamic>> playAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return {
          'success': false,
          'error': 'Audio file not found: $filePath',
        };
      }

      await _player.stop();
      await _player.play(DeviceFileSource(filePath));

      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Playback error: $e',
      };
    }
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  /// Dispose resources
  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
