// lib/core/storage/secure_storage_service.dart
//
// Implements [F4] Local Data Storage principle.
// This service handles saving and retrieving the secret mnemonic
// phrase from the device's secure keychain/keystore.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {che
  final _storage = const FlutterSecureStorage();
  static const _keyMnemonic = 'citadel_mnemonic';

  /// Saves the mnemonic phrase securely.
  Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(key: _keyMnemonic, value: mnemonic);
  }

  /// Retrieves the stored mnemonic phrase.
  /// Returns null if no mnemonic is stored.
  Future<String?> getMnemonic() async {
    return await _storage.read(key: _keyMnemonic);
  }

  /// Deletes the mnemonic phrase. Used for logging out or resetting the app.
  Future<void> deleteMnemonic() async {
    await _storage.delete(key: _keyMnemonic);
  }
}
