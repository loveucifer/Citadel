// lib/features/onboarding/generate_identity_screen.dart
// (Updated to save the identity and navigate)

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../core/identity/citadel_identity.dart';
import '../../core/storage/secure_storage_service.dart';
import 'recover_identity_screen.dart';
import '../home/home_screen.dart';

class GenerateIdentityScreen extends StatefulWidget {
  const GenerateIdentityScreen({Key? key}) : super(key: key);

  @override
  State<GenerateIdentityScreen> createState() => _GenerateIdentityScreenState();
}

class _GenerateIdentityScreenState extends State<GenerateIdentityScreen> {
  CitadelIdentity? _identity;
  bool _isSaving = false;

  void _generateNewIdentity() {
    final newIdentity = CitadelIdentity.generate();
    setState(() {
      _identity = newIdentity;
    });
  }

  Future<void> _confirmAndSaveIdentity() async {
    if (_identity == null) return;

    setState(() { _isSaving = true; });

    // Save the mnemonic securely
    final storage = GetIt.instance<SecureStorageService>();
    await storage.saveMnemonic(_identity!.mnemonic);

    // Navigate to the main app, replacing the onboarding flow
    if (mounted) {
       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Provider<CitadelIdentity>.value(
            value: _identity!,
            // We would normally initialize services here too, but for simplicity
            // we'll rely on the app restart logic in main.dart. A better
            // approach would be to pass the loaded identity to a home screen
            // that then initializes the other services.
            child: const HomeScreen(),
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Citadel Identity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _identity == null
              ? _buildGenerateUI()
              : _buildConfirmUI(),
        ),
      ),
    );
  }

  Widget _buildGenerateUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Welcome to Citadel.\n\nPress the button below to create your secure, private identity.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _generateNewIdentity,
          child: const Text('Generate New Identity'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecoverIdentityScreen()));
          },
          child: const Text('Or recover an existing identity'),
        ),
      ],
    );
  }

  Widget _buildConfirmUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
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
                SelectableText(
                  _identity!.mnemonic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'I have written down my recovery phrase.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _isSaving
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _confirmAndSaveIdentity,
                child: const Text('Confirm & Enter Citadel'),
              ),
      ],
    );
  }
}

