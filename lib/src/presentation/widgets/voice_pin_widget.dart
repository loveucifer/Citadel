// File: lib/src/presentation/widgets/voice_pin_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:citadel/main.dart'; // To access audioServiceProvider
import 'package:citadel/src/models/voice_pin.dart';
import 'package:citadel/src/utils/app_theme.dart';

class VoicePinWidget extends ConsumerStatefulWidget {
  final VoicePin pin;
  const VoicePinWidget({super.key, required this.pin});

  @override
  ConsumerState<VoicePinWidget> createState() => _VoicePinWidgetState();
}

class _VoicePinWidgetState extends ConsumerState<VoicePinWidget> {
  late final PlayerController _playerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    // Prepare the player with the audio data but don't start playing.
    _playerController.preparePlayer(
      path: '', // Not used when playing from a buffer
      noOfSamples: 100, // Controls the density of the waveform
    );

    // Listen to player state changes to update the UI
    _playerController.onPlayerStateChanged.listen((state) {
      final isPlaying = state == PlayerState.playing;
      if (_isPlaying != isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  void _onPlayPause() {
    final audioService = ref.read(audioServiceProvider);
    if (_isPlaying) {
      audioService.stopPlayback();
      _playerController.pausePlayer();
    } else {
      // Start playing the audio using the audio service
      audioService.playAudio(widget.pin.encryptedAudioData);
      // And also start the waveform animation
      _playerController.startPlayer(
        finishMode: FinishMode.pause,
        // We use the encrypted data for the waveform. In a real app, you'd
        // decrypt first and generate the waveform from the raw audio.
        // For this prototype, this visual representation is sufficient.
        playerWaveStyle: const PlayerWaveStyle(
          fixedWaveColor: AppTheme.subtleTextColor,
          liveWaveColor: AppTheme.accentColor,
          spacing: 6,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for metadata: time and sentiment tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('h:mm a').format(widget.pin.timestamp),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.pin.sentimentTag,
                    style: const TextStyle(
                        color: AppTheme.textColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row for the play button and waveform
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: AppTheme.accentColor,
                    size: 40,
                  ),
                  onPressed: _onPlayPause,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AudioFileWaveforms(
                    size: const Size(double.infinity, 50.0),
                    playerController: _playerController,
                    enableSeekGesture: false,
                  ),
                ),
              ],
            ),
            // Optional: Show reply thread indicator
            if (widget.pin.parentThreadId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.subdirectory_arrow_left,
                        size: 16, color: AppTheme.subtleTextColor),
                    const SizedBox(width: 4),
                    Text(
                      "Reply in thread",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
