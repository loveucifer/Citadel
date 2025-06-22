// lib/features/onboarding/generate_identity_screen.dart
//
// This is the first screen a new user will see.
// Its purpose is to create a new identity and display the
// all-important 12-word recovery phrase.

import 'package:flutter/material.dart';
import '../../core/identity/citadel_identity.dart'; // We import our identity engine!

class GenerateIdentityScreen extends StatefulWidget {
  const GenerateIdentityScreen({Key? key}) : super(key: key);

  @override
  State<GenerateIdentityScreen> createState() => _GenerateIdentityScreenState();
}

class _GenerateIdentityScreenState extends State<GenerateIdentityScreen> {
  // This variable will hold our generated identity.
  // It's nullable (the '?') because it won't exist until the user clicks the button.
  CitadelIdentity? _identity;

  // This is the main function that gets called when the user presses the button.
  void _generateNewIdentity() {
    final newIdentity = CitadelIdentity.generate();

    // setState() is a special Flutter function. It tells the framework
    // that our data has changed and the screen needs to be redrawn
    // to show the new data.
    setState(() {
      _identity = newIdentity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Citadel Identity'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // We use an 'if' statement directly in our UI code.
              // If the identity has NOT been generated yet, show instructions.
              if (_identity == null)
                const Text(
                  'Welcome to Citadel.\n\nPress the button below to create your secure, private identity. No email or phone number required.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

              // If the identity HAS been generated, show the recovery phrase.
              if (_identity != null)
                Card(
                  elevation: 4.0,
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '🚨 IMPORTANT 🚨',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Write down these 12 words and store them somewhere safe. This is the ONLY way to recover your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _identity!.mnemonic, // The '!' means we are SURE _identity is not null here.
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40), // Just for spacing

              // The main button.
              ElevatedButton(
                // If identity is null, show the "Generate" button.
                // Otherwise, the button is hidden because the phrase is shown.
                onPressed: _identity == null ? _generateNewIdentity : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Generate New Identity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
