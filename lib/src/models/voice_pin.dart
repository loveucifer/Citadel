// File: lib/src/models/voice_pin.dart

import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:typed_data';

// This line is generated by the build_runner. We'll run it later.
part 'voice_pin.g.dart';

// A unique typeId for the Hive adapter. Each HiveObject needs a unique ID.
@HiveType(typeId: 0)
class VoicePin extends HiveObject {
  // --- Core Properties ---

  // A unique identifier for this specific voice pin.
  @HiveField(0)
  final String uuid;

  // The UUID of the message this pin is a reply to. Can be null for top-level pins.
  @HiveField(1)
  final String? parentThreadId;

  // The raw, compressed, and encrypted audio data.
  @HiveField(2)
  final Uint8List encryptedAudioData;

  // The timestamp when the pin was created.
  @HiveField(3)
  final DateTime timestamp;

  // The session ID of the user who created the pin.
  @HiveField(4)
  final String authorSessionId;

  // --- Optional Metadata ---

  // Mocked geographical latitude.
  @HiveField(5)
  double? latitude;

  // Mocked geographical longitude.
  @HiveField(6)
  double? longitude;

  // A placeholder for sentiment analysis.
  @HiveField(7)
  String sentimentTag; // e.g., "neutral", "happy", "sad"

  VoicePin({
    required this.uuid,
    this.parentThreadId,
    required this.encryptedAudioData,
    required this.timestamp,
    required this.authorSessionId,
    this.latitude,
    this.longitude,
    this.sentimentTag = 'neutral', // Default sentiment
  });

  // --- Serialization for Mesh Network ---

  /// Converts the VoicePin metadata into a JSON map for broadcasting.
  /// Note: The audio data is sent separately in chunks. This is for the
  /// "header" packet that describes the incoming message.
  Map<String, dynamic> toMapForMesh() {
    return {
      'uuid': uuid,
      'parentThreadId': parentThreadId,
      'timestamp': timestamp.toIso8601String(),
      'authorSessionId': authorSessionId,
      'latitude': latitude,
      'longitude': longitude,
      'sentimentTag': sentimentTag,
      // We also include the total data length so the receiver knows how many chunks to expect.
      'totalDataLength': encryptedAudioData.length,
    };
  }

  /// Creates a VoicePin from a JSON map received over the mesh network.
  /// The `encryptedAudioData` will be reassembled from chunks and added separately.
  factory VoicePin.fromMapForMesh(Map<String, dynamic> map, Uint8List reassembledData) {
    return VoicePin(
      uuid: map['uuid'],
      parentThreadId: map['parentThreadId'],
      timestamp: DateTime.parse(map['timestamp']),
      authorSessionId: map['authorSessionId'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      sentimentTag: map['sentimentTag'] ?? 'neutral',
      encryptedAudioData: reassembledData,
    );
  }

  /// Encodes the metadata map into a UTF8 string for transport.
  String toJsonForMesh() => json.encode(toMapForMesh());

  /// Decodes a UTF8 string back into a map.
  static Map<String, dynamic> getMapFromJson(String jsonString) => json.decode(jsonString);
}
