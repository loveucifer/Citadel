// File: lib/src/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citadel/main.dart'; // To access meshServiceProvider
import 'package:citadel/src/presentation/screens/feed_screen.dart';
import 'package:citadel/src/utils/app_theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  void _navigateToFeed(BuildContext context) {
    // We use a pushReplacement to prevent the user from navigating back to the splash screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const FeedScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the MeshService to react to changes in provisioning status.
    final meshService = ref.watch(meshServiceProvider);

    // Use a post-frame callback to navigate after the build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (meshService.isProvisioned) {
        _navigateToFeed(context);
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A simple visual indicator for the app
            const Icon(
              Icons.hearing_rounded,
              size: 80,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Citadel',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Connecting to the local mesh network...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.subtleTextColor,
                    ),
              ),
            ),
            const SizedBox(height: 40),
            // Show a loading indicator while we wait
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 40),
            // If not provisioned, show a button to start the process
            if (!meshService.isProvisioned)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.textColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                // When pressed, call the provision method in the service
                onPressed: () => ref.read(meshServiceProvider.notifier).provision(),
                child: const Text('Join Network'),
              )
          ],
        ),
      ),
    );
  }
}
