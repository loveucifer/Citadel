// File: lib/src/presentation/screens/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:citadel/main.dart'; // To access storageServiceProvider
import 'package:citadel/src/models/voice_pin.dart';
import 'package:citadel/src/services/storage_service.dart';
import 'package:citadel/src/presentation/screens/recorder_screen.dart';
import 'package:citadel/src/presentation/widgets/voice_pin_widget.dart';
import 'package:citadel/src/utils/app_theme.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the storage service to get access to the pins box
    final storageService = ref.watch(storageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empathy Feed'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<VoicePin>>(
        // Listen directly to the Hive box for real-time UI updates
        valueListenable: storageService.getPinsBox().listenable(),
        builder: (context, box, _) {
          final pins = storageService.getAllPins();

          if (pins.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 60,
                      color: AppTheme.subtleTextColor.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'The air is quiet...',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Be the first to share a thought. Tap the + button to record a voice pin.',
                      style: TextStyle(fontSize: 16, color: AppTheme.subtleTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Display the list of voice pins
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pins.length,
            itemBuilder: (context, index) {
              final pin = pins[index];
              // We will create this widget in the next step
              return VoicePinWidget(pin: pin);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const RecorderScreen()),
          );
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: AppTheme.textColor, size: 28),
      ),
    );
  }
}
