// File: lib/src/services/encryption_service.dart

import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

/// A service class for handling AES-GCM encryption and decryption of audio data.
/// This uses a static implementation as the service is stateless.
class EncryptionService {
  // --- SECURITY WARNING ---
  // For this prototype, we are using a hardcoded, fixed key and IV.
  // In a real-world application, this is highly insecure. A production-grade
  // system would require a secure key exchange mechanism (e.g., ECDH)
  // over the mesh network to establish a shared secret for each session or group.

  // A 32-byte (256-bit) key. MUST be kept secret.
  static final _key = enc.Key.fromUtf8('a_32_byte_long_secret_key_for_aes');

  // A 12-byte (96-bit) Initialization Vector (IV). Does not need to be secret,
  // but should be unique for each encryption operation with the same key.
  // For GCM, it's critical that the (key, IV) pair is never reused.
  // Here, we use a fixed IV for simplicity, but in a real app, you might
  // generate a random IV and prepend it to the ciphertext.
  static final _iv = enc.IV.fromUtf8('a_12_byte_long_iv');

  // The AES encrypter instance using GCM mode.
  static final _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.gcm));

  /// Encrypts a given piece of data.
  ///
  /// Takes a [Uint8List] of raw data and returns the encrypted data as a [Uint8List].
  static Uint8List encrypt(Uint8List plainData) {
    try {
      final encrypted = _encrypter.encryptBytes(plainData, iv: _iv);
      debugPrint("Successfully encrypted ${plainData.length} bytes.");
      return encrypted.bytes;
    } catch (e) {
      debugPrint("Encryption failed: $e");
      // In a real app, handle this error more gracefully.
      rethrow;
    }
  }

  /// Decrypts a given piece of encrypted data.
  ///
  /// Takes a [Uint8List] of encrypted data and returns the original raw data.
  /// Throws an exception if the decryption fails (e.g., due to data corruption
  /// or incorrect key/IV), which is a feature of GCM's authenticity check.
  static Uint8List decrypt(Uint8List encryptedData) {
    try {
      final encryptedObject = enc.Encrypted(encryptedData);
      final decrypted = _encrypter.decryptBytes(encryptedObject, iv: _iv);
      debugPrint("Successfully decrypted ${encryptedData.length} bytes.");
      return Uint8List.fromList(decrypted);
    } catch (e) {
      debugPrint("Decryption failed. Data might be corrupt or tampered with. Error: $e");
      // This failure is important. It means the message is not authentic.
      rethrow;
    }
  }
}
