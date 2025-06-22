// lib/features/onboarding/recover_identity_screen.dart
// (Updated to save the identity and navigate)

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../core/identity/citadel_identity.dart';
import '../../core/storage/secure_storage_service.dart';
import '../home/home_screen.dart';

class RecoverIdentityScreen extends StatefulWidget {
  const RecoverIdentityScreen({Key? key}) : super(key: key);

  @override
  State<RecoverIdentityScreen> createState() => _RecoverIdentityScreenState();
}

class _RecoverIdentityScreenState extends State<RecoverIdentityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String? _errorMessage;
  bool _isRecovering = false;

  Future<void> _recoverAndSaveIdentity() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isRecovering = true;
      _errorMessage = null;
    });

    final mnemonic = _textController.text.trim();
    
    try {
      final recoveredIdentity = CitadelIdentity.fromMnemonic(mnemonic);

      final storage = GetIt.instance<SecureStorageService>();
      await storage.saveMnemonic(recoveredIdentity.mnemonic);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Provider<CitadelIdentity>.value(
              value: recoveredIdentity,
              child: const HomeScreen(),
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to recover. Please check your phrase.';
        _isRecovering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recover Identity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter your 12-word secret recovery phrase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Recovery Phrase',
                  hintText: 'word1 word2 word3 ...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().split(' ').length != 12) {
                    return 'Please enter exactly 12 words.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isRecovering
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _recoverAndSaveIdentity,
                      child: const Text('Recover & Enter Citadel'),
                    ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
