// File: lib/src/presentation/screens/recorder_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:citadel/main.dart';
import 'package:citadel/src/models/voice_pin.dart';
import 'package:citadel/src/services/encryption_service.dart';
import 'package:citadel/src/utils/app_theme.dart';
import 'package:citadel/src/presentation/widgets/pulsing_record_button.dart';

class RecorderScreen extends ConsumerStatefulWidget {
  /// The ID of the pin this recording is a reply to. Null for a new thread.
  final String? parentThreadId;

  const RecorderScreen({super.key, this.parentThreadId});

  @override
  ConsumerState<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends ConsumerState<RecorderScreen> {
  Timer? _timer;
  int _recordDuration = 0;
  final int _maxDuration = 15; // Max recording time in seconds

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
      if (_recordDuration >= _maxDuration) {
        _stopRecordingAndBroadcast();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startRecording() async {
    final audioService = ref.read(audioServiceProvider);
    await audioService.startRecording();
    _startTimer();
  }

  Future<void> _stopRecordingAndBroadcast() async {
    _stopTimer();
    final audioService = ref.read(audioServiceProvider);
    final meshService = ref.read(meshServiceProvider.notifier);
    final storageService = ref.read(storageServiceProvider);

    if (!audioService.isRecording) return;

    final audioData = await audioService.stopRecording();

    if (audioData != null) {
      // 1. Encrypt the audio data
      final encryptedData = EncryptionService.encrypt(audioData);

      // 2. Create a new VoicePin
      final newPin = VoicePin(
        uuid: const Uuid().v4(),
        parentThreadId: widget.parentThreadId,
        encryptedAudioData: encryptedData,
        timestamp: DateTime.now(),
        // In a real app, this would be a unique session ID generated at launch
        authorSessionId: 'user_session_placeholder',
      );

      // 3. Save it locally first
      await storageService.savePin(newPin);

      // 4. Broadcast it to the mesh network
      await meshService.broadcastVoicePin(newPin);

      // 5. Close the recorder screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor.withOpacity(0.95),
      appBar: AppBar(
        title: Text(widget.parentThreadId == null ? 'New Voice Pin' : 'Reply'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_recordDuration}s / ${_maxDuration}s',
              style: const TextStyle(fontSize: 24, color: AppTheme.textColor),
            ),
            const SizedBox(height: 40),
            Text(
              audioService.isRecording ? 'Recording...' : 'Tap to Record',
              style: const TextStyle(fontSize: 18, color: AppTheme.subtleTextColor),
            ),
            const SizedBox(height: 20),
            PulsingRecordButton(
              isRecording: audioService.isRecording,
              onTap: () {
                if (audioService.isRecording) {
                  _stopRecordingAndBroadcast();
                } else {
                  _startRecording();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
