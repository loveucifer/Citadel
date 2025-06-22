// lib/main.dart
//
// This is the main entry point for the Citadel application.
// Its only job is to start the app and tell it which screen to show first.

import 'package:flutter/material.dart';
import 'features/onboarding/generate_identity_screen.dart'; // We import our new screen.

void main() {
  runApp(const CitadelApp());
}

class CitadelApp extends StatelessWidget {
  const CitadelApp({Key? key}) : super(key: key);

  // This build method is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citadel',
      theme: ThemeData(
        // We're setting a simple color theme for the whole app.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Here is the most important line:
      // We are setting our GenerateIdentityScreen as the home screen.
      home: const GenerateIdentityScreen(),
      debugShowCheckedModeBanner: false, // This removes the little "Debug" banner.
    );
  }
}
