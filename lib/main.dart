// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citadel/src/services/storage_service.dart';
import 'package:citadel/src/services/audio_service.dart';
import 'package:citadel/src/services/mesh_service.dart';
import 'package:citadel/src/presentation/screens/splash_screen.dart';
import 'package:citadel/src/utils/app_theme.dart';

// --- Service Providers ---
// Using Riverpod to provide our service instances to the entire app.
// This makes them easily accessible and testable.

/// Provider for the singleton StorageService instance.
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

/// Provider for the AudioService.
/// It uses `ChangeNotifierProvider` because AudioService notifies listeners of state changes.
final audioServiceProvider = ChangeNotifierProvider<AudioService>((ref) => AudioService());

/// Provider for the MeshService.
/// Depends on StorageService, which Riverpod handles automatically.
final meshServiceProvider = ChangeNotifierProvider<MeshService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return MeshService(storageService);
});


Future<void> main() async {
  // Ensure that Flutter widgets are initialized before we run any other code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize our core services before the app runs.
  // We create a temporary ProviderContainer to access the providers
  // outside the widget tree.
  final container = ProviderContainer();
  await container.read(storageServiceProvider).init();
  await container.read(audioServiceProvider).init();
  await container.read(meshServiceProvider).init();
  
  // Run the app, wrapped in a ProviderScope to make providers available to all widgets.
  runApp(
    ProviderScope(
      parent: container,
      child: const CitadelApp(),
    ),
  );
}

class CitadelApp extends StatelessWidget {
  const CitadelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citadel',
      theme: AppTheme.softPastelTheme,
      debugShowCheckedModeBanner: false,
      // We start with a SplashScreen to handle any further async setup
      // and to decide whether to show the feed or the provisioning screen.
      home: const SplashScreen(),
    );
  }
}
