// lib/features/onboarding/generate_identity_screen.dart
//
// This is the first screen a new user will see.
// Its purpose is to create a new identity and display the
// all-important 12-word recovery phrase.
// VERSION 2: Adds a button to navigate to the recovery screen.

import 'package:flutter/material.dart';
import '../../core/identity/citadel_identity.dart';
import 'recover_identity_screen.dart'; // <<< CHANGE #1: Import the new screen.

class GenerateIdentityScreen extends StatefulWidget {
  const GenerateIdentityScreen({Key? key}) : super(key: key);

  @override
  State<GenerateIdentityScreen> createState() => _GenerateIdentityScreenState();
}

class _GenerateIdentityScreenState extends State<GenerateIdentityScreen> {
  CitadelIdentity? _identity;

  void _generateNewIdentity() {
    final newIdentity = CitadelIdentity.generate();
    setState(() {
      _identity = newIdentity;
    });
  }
  
  // <<< CHANGE #2: New function to handle navigation.
  void _navigateToRecoveryScreen() {
    // Navigator.push() is how we move to a new screen in Flutter.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecoverIdentityScreen(),
      ),
    );
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
              if (_identity == null)
                const Text(
                  'Welcome to Citadel.\n\nPress the button below to create your secure, private identity. No email or phone number required.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

              if (_identity != null)
                Card(
                  elevation: 4.0,
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('🚨 IMPORTANT 🚨', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        const Text('Write down these 12 words and store them somewhere safe. This is the ONLY way to recover your account.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        Text(
                          _identity!.mnemonic,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // We only show these buttons if an identity hasn't been generated yet.
              if (_identity == null) ...[
                ElevatedButton(
                  onPressed: _generateNewIdentity,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Generate New Identity'),
                ),

                const SizedBox(height: 16),

                // <<< CHANGE #3: The new button to go to the recovery screen.
                TextButton(
                  onPressed: _navigateToRecoveryScreen,
                  child: const Text(
                    'Or recover an existing identity',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
