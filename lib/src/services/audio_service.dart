// File: lib/src/services/audio_service.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// A unique filename for our temporary recording file.
const String _kRecordingFileName = 'citadel_temp_recording.aac';

/// A service class to manage audio recording and playback.
/// It uses ChangeNotifier to notify listeners (like the UI) about state changes.
class AudioService with ChangeNotifier {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;

  // --- State Properties ---
  bool get isRecording => _recorder.isRecording;
  bool get isPlaying => _player.isPlaying;
  Stream<RecordingDisposition>? get onRecorderProgress => _recorder.onProgress;

  String? _recordingPath;

  /// Initializes the audio service, setting up the recorder and player.
  /// This must be called before any other methods.
  Future<void> init() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    await _recorder.openRecorder();
    await _player.openPlayer();

    _isRecorderInitialized = true;
    _isPlayerInitialized = true;

    // Set the subscription duration for recorder progress updates.
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));

    debugPrint("AudioService initialized.");
  }

  /// Disposes of the recorder and player resources.
  /// Should be called when the service is no longer needed.
  Future<void> dispose() async {
    await _recorder.closeRecorder();
    await _player.closePlayer();
    super.dispose();
  }

  /// Starts the audio recording process.
  /// The recording is saved to a temporary file.
  Future<void> startRecording() async {
    if (!_isRecorderInitialized) {
      debugPrint("Recorder not initialized.");
      return;
    }

    final tempDir = await getTemporaryDirectory();
    _recordingPath = '${tempDir.path}/$_kRecordingFileName';

    await _recorder.startRecorder(
      toFile: _recordingPath,
      codec: Codec.aacADTS, // A good codec for quality and compression
    );

    notifyListeners(); // Notify UI that recording has started
    debugPrint("Recording started. Saving to $_recordingPath");
  }

  /// Stops the audio recording and returns the audio data as a Uint8List.
  /// This method also cleans up the temporary file.
  Future<Uint8List?> stopRecording() async {
    if (!_isRecorderInitialized || !_recorder.isRecording) {
      debugPrint("Recorder not initialized or not recording.");
      return null;
    }

    await _recorder.stopRecorder();
    notifyListeners(); // Notify UI that recording has stopped
    debugPrint("Recording stopped.");

    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        final fileBytes = await file.readAsBytes();
        await file.delete(); // Clean up the temp file
        _recordingPath = null;
        debugPrint("Temporary recording file deleted.");
        return fileBytes;
      }
    }
    return null;
  }

  /// Plays audio from a given [Uint8List].
  /// This is used to play back received voice notes.
  Future<void> playAudio(Uint8List audioData) async {
    if (!_isPlayerInitialized || isPlaying) {
      debugPrint("Player not initialized or already playing.");
      return;
    }

    await _player.startPlayer(
      fromDataBuffer: audioData,
      codec: Codec.aacADTS,
      whenFinished: () {
        notifyListeners(); // Notify UI that playback has finished
        debugPrint("Playback finished.");
      },
    );

    notifyListeners(); // Notify UI that playback has started
    debugPrint("Playing audio from buffer.");
  }

  /// Stops the current audio playback.
  Future<void> stopPlayback() async {
    if (!_isPlayerInitialized) return;
    await _player.stopPlayer();
    notifyListeners(); // Notify UI that playback has stopped
    debugPrint("Playback stopped by user.");
  }
}
