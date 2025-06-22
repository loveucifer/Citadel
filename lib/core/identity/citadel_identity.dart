
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:pinenacl/ed25519.dart';

// Note: We use the 'as bip39' part to avoid confusion if another library
// had a function with the same name. It's like giving the library a nickname.


/// ## CitadelIdentity
///
/// This class is a digital container for a user's identity.
/// It holds the secret recovery phrase and the master cryptographic key.
class CitadelIdentity {
  /// The secret 12-word recovery phrase.
  /// Example: "witch collapse practice feed shame open despair creek road again ice least"
  /// This is the most important piece of information for the user to keep safe.
  final String mnemonic;

  /// The master key for signing and verification. This is derived from the mnemonic.
  /// Think of it as the user's unique, unforgeable signature.
  final SigningKey identityKey;


  // This is a private constructor. It means we can only create an instance
  // of this class using our special methods below (`generate` or `fromMnemonic`).
  CitadelIdentity._({required this.mnemonic, required this.identityKey});


  /// ### `generate()`
  ///
  /// This is a special "factory" method that creates a brand new Citadel Identity.
  /// This is what a new user will use when they open the app for the first time.
  static CitadelIdentity generate() {
    // 1. Generate a new, random 12-word mnemonic phrase.
    // The `bip39.generateMnemonic()` function handles all the complex cryptography
    // to ensure it's truly random and secure.
    final newMnemonic = bip39.generateMnemonic();

    // 2. Convert the user-friendly words into a binary "seed".
    // This seed is what we use to generate the actual keys. The same words will
    // ALWAYS produce the exact same seed.
    final seed = bip39.mnemonicToSeed(newMnemonic);
    
    // We only need the first 32 bytes of the seed for our main identity key.
    final identitySeed = Uint8List.fromList(seed.sublist(0, 32));

    // 3. Generate the master signing key from that seed.
    final newIdentityKey = SigningKey.fromSeed(identitySeed);

    // 4. Return a new CitadelIdentity object containing the phrase and the key.
    return CitadelIdentity._(mnemonic: newMnemonic, identityKey: newIdentityKey);
  }


  /// ### `fromMnemonic()`
  ///
  /// This factory method restores an identity from a saved mnemonic phrase.
  /// This is the "account recovery" function.
  static CitadelIdentity fromMnemonic(String existingMnemonic) {
    // 1. First, we check if the mnemonic is a valid 12-word phrase.
    if (!bip39.validateMnemonic(existingMnemonic)) {
      // If it's not valid, we stop and report an error.
      throw ArgumentError('Invalid mnemonic phrase provided.');
    }

    // 2. The process is identical to generating a new key.
    // We convert the words to a seed, and the seed to a key.
    // This guarantees that restoring from a phrase gives you the exact same key you started with.
    final seed = bip39.mnemonicToSeed(existingMnemonic);
    final identitySeed = Uint8List.fromList(seed.sublist(0, 32));
    final restoredIdentityKey = SigningKey.fromSeed(identitySeed);

    // 3. Return the restored identity.
    return CitadelIdentity._(mnemonic: existingMnemonic, identityKey: restoredIdentityKey);
  }
}
