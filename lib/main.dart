// lib/main.dart
//
// This is the main entry point for the Citadel application.
// It initializes core services and determines the initial screen.

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'core/identity/citadel_identity.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/database/database_service.dart';
import 'core/network/network_manager.dart';

import 'features/onboarding/generate_identity_screen.dart';
import 'features/home/home_screen.dart'; // We will create this screen next

// Create a simple Service Locator
final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton(() => SecureStorageService());
  sl.registerLazySingleton(() => DatabaseService());
  sl.registerLazySingleton(() => NetworkManager());
  // We register the identity as a factory because it will be created on-demand
  sl.registerFactory<CitadelIdentity>(() => throw Exception("Identity not loaded"));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  
  // Check if an identity already exists
  final storage = sl<SecureStorageService>();
  final mnemonic = await storage.getMnemonic();

  runApp(CitadelApp(mnemonic: mnemonic));
}

class CitadelApp extends StatelessWidget {
  final String? mnemonic;

  const CitadelApp({Key? key, this.mnemonic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citadel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: mnemonic == null
          ? const GenerateIdentityScreen()
          : FutureBuilder<CitadelIdentity>(
              future: _loadIdentityAndInitServices(mnemonic!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // If identity is loaded, provide it to the app and go home
                  return Provider<CitadelIdentity>.value(
                    value: snapshot.data!,
                    child: const HomeScreen(),
                  );
                }
                if (snapshot.hasError) {
                  // Handle error, maybe show an error screen
                  return const Scaffold(body: Center(child: Text("Fatal Error: Could not load identity.")));
                }
                // While loading, show a splash screen
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              },
            ),
    );
  }

  // This function loads the existing identity and starts all core services
  Future<CitadelIdentity> _loadIdentityAndInitServices(String existingMnemonic) async {
    final identity = CitadelIdentity.fromMnemonic(existingMnemonic);
    
    // Register the loaded identity with our service locator
    sl.registerSingleton<CitadelIdentity>(identity);

    // Use a part of the identity's key to create a unique, secure password
    // for the database.
    final dbPassword = identity.identityKey.encode(encoder: Base64Encoder.instance).substring(0, 32);
    
    // Initialize services
    await sl<DatabaseService>().init(dbPassword);
    await sl<NetworkManager>().start(identity);

    return identity;
  }
}
