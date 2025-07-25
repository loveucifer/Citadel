// File: lib/src/services/mesh_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nordic_nrf_mesh/nordic_nrf_mesh.dart';
import '../models/voice_pin.dart';
import 'encryption_service.dart';
import 'storage_service.dart';

// A constant for the maximum data size per mesh packet.
// BLE has strict limits, so we choose a safe value under the theoretical max.
const int _maxPacketSize = 200;

// A constant for the company ID, required for vendor-specific models.
const int _companyId = 0x0159; // Nordic Semiconductor's Company ID

// A constant for our custom model ID.
const int _modelId = 0x0001;

/// Service to manage all BLE Mesh network operations.
/// It handles provisioning, message sending (chunking), and receiving (reassembly).
class MeshService with ChangeNotifier {
  final StorageService _storageService;
  final MeshManagerApi _meshManagerApi;
  late final MeshNetwork? _meshNetwork;
  late final Provisioner _provisioner;
  late final MeshProvisioning _provisioning;
  late final MeshMessaging _messaging;

  // Map to store the parsed header of an incoming message.
  // Key: UUID of the voice pin. Value: The decoded JSON map from the header packet.
  final Map<String, Map<String, dynamic>> _incomingHeaders = {};
  // Map to store incoming chunks of data while they are being reassembled.
  // Key: UUID of the voice pin. Value: Map of sequence number to data chunk.
  final Map<String, Map<int, Uint8List>> _incomingDataChunks = {};
  // Map to store the total expected length of a message's audio data.
  // Key: UUID of the voice pin. Value: Total byte length.
  final Map<String, int> _expectedDataLengths = {};

  String? _provisionerUuid;
  int? _unicastAddress;

  // --- State Properties ---
  bool isProvisioned = false;

  MeshService(this._storageService) : _meshManagerApi = MeshManagerApi();

  /// Initializes the mesh service, loads the network, and sets up listeners.
  Future<void> init() async {
    _meshNetwork = await _meshManagerApi.loadMeshNetwork();

    _provisioning = _meshManagerApi.meshProvisioning;
    _provisioning.onProvisioningStateChanged.listen((event) {
      debugPrint("Provisioning state changed: $event");
    });
    _provisioning.onProvisioningCompleted.listen((event) {
      isProvisioned = true;
      _unicastAddress = event.unicastAddress;
      notifyListeners();
      debugPrint("Provisioning completed. Unicast Address: $_unicastAddress");
      _setupMessaging();
    });

    final provisioners = await _meshNetwork!.provisioners;
    if (provisioners.isNotEmpty) {
      _provisioner = provisioners.first;
      _provisionerUuid = _provisioner.provisionerUuid;
      final nodes = await _meshNetwork!.nodes;
      if (nodes.isNotEmpty) {
        isProvisioned = true;
        _unicastAddress = nodes.first.unicastAddress;
        _setupMessaging();
      }
    } else {
      _provisioner = await _meshNetwork!.addProvisioner(0x1234);
      _provisionerUuid = _provisioner.provisionerUuid;
    }

    await _meshManagerApi.startMqttService();
    debugPrint("MeshService initialized. Provisioner UUID: $_provisionerUuid");
  }

  /// Starts the provisioning process for this device.
  Future<void> provision() async {
    final unprovisionedNodes = await _meshManagerApi.unprovisionedNodes;
    if (unprovisionedNodes.isEmpty) {
      debugPrint("No unprovisioned nodes found to provision.");
      return;
    }
    final selfNode = unprovisionedNodes.first;
    await _provisioning.provision(selfNode, _meshNetwork!.netKeys.first.key);
  }

  /// Sets up the listeners for incoming mesh messages.
  void _setupMessaging() {
    _messaging = MeshMessaging(_meshManagerApi, _unicastAddress!);
    _messaging.onMessageReceived.listen((message) {
      debugPrint("Mesh message received from ${message.src}");
      _handleIncomingPacket(message.data);
    });
  }

  /// Main method to broadcast a voice pin over the mesh network.
  Future<void> broadcastVoicePin(VoicePin pin) async {
    if (!isProvisioned) {
      debugPrint("Cannot broadcast: device is not provisioned.");
      return;
    }

    final headerMap = pin.toMapForMesh();
    final headerJson = json.encode(headerMap);
    final headerData = Uint8List.fromList(utf8.encode(headerJson));
    await _sendChunk(pin.uuid, 0, headerData, isHeader: true);

    final audioData = pin.encryptedAudioData;
    int sequence = 1;
    for (int i = 0; i < audioData.length; i += _maxPacketSize) {
      final end = (i + _maxPacketSize > audioData.length) ? audioData.length : i + _maxPacketSize;
      final chunk = audioData.sublist(i, end);
      await _sendChunk(pin.uuid, sequence, chunk);
      sequence++;
      await Future.delayed(const Duration(milliseconds: 50));
    }
    debugPrint("Finished broadcasting all chunks for pin ${pin.uuid}");
  }

  /// Sends a single data chunk over the mesh.
  Future<void> _sendChunk(String uuid, int sequence, Uint8List data, {bool isHeader = false}) async {
    final uuidBytes = utf8.encode(uuid);
    final sequenceBytes = ByteData(4)..setInt32(0, sequence);

    final builder = BytesBuilder();
    builder.addByte(isHeader ? 1 : 0);
    builder.add(uuidBytes);
    builder.add(sequenceBytes.buffer.asUint8List());
    builder.add(data);

    final packet = builder.toBytes();
    await _messaging.send(await _meshNetwork!.groups.first.address, packet);
    debugPrint("Sent chunk #$sequence for UUID $uuid");
  }

  /// Handles an incoming raw data packet from the mesh network.
  void _handleIncomingPacket(Uint8List packet) {
    try {
      final isHeader = packet[0] == 1;
      final uuid = utf8.decode(packet.sublist(1, 37));
      final sequence = ByteData.sublistView(packet, 37, 41).getInt32(0);
      final data = packet.sublist(41);

      if (isHeader) {
        final headerJson = utf8.decode(data);
        final headerMap = json.decode(headerJson) as Map<String, dynamic>;
        _incomingHeaders[uuid] = headerMap;
        _expectedDataLengths[uuid] = headerMap['totalDataLength'];
        _incomingDataChunks[uuid] = {}; // Initialize/reset chunk map
        debugPrint("Received header for $uuid. Expecting ${_expectedDataLengths[uuid]} bytes.");
      } else {
        if (!_incomingDataChunks.containsKey(uuid)) {
          debugPrint("Received data chunk for unknown UUID $uuid. Discarding.");
          return;
        }
        _incomingDataChunks[uuid]![sequence] = data;
        debugPrint("Received chunk #$sequence for $uuid. Size: ${data.length}");
        _checkForCompletion(uuid);
      }
    } catch (e) {
      debugPrint("Error processing incoming packet: $e");
    }
  }

  /// Checks if all chunks for a given message have been received.
  /// If so, it reassembles, decrypts, and saves the voice pin.
  void _checkForCompletion(String uuid) {
    final chunks = _incomingDataChunks[uuid];
    final expectedLength = _expectedDataLengths[uuid];
    final header = _incomingHeaders[uuid];

    if (chunks == null || expectedLength == null || header == null) return;

    final totalReceivedLength = chunks.values.fold<int>(0, (sum, chunk) => sum + chunk.length);

    if (totalReceivedLength >= expectedLength) {
      debugPrint("All chunks received for $uuid. Reassembling...");
      final sortedKeys = chunks.keys.toList()..sort();
      final builder = BytesBuilder();
      for (final key in sortedKeys) {
        if (key > 0) {
          builder.add(chunks[key]!);
        }
      }
      final reassembledEncryptedData = builder.toBytes();

      try {
        // Decrypt the reassembled data
        final decryptedData = EncryptionService.decrypt(reassembledEncryptedData);
        // Create the VoicePin object from the stored header and decrypted data
        final pin = VoicePin.fromMapForMesh(header, decryptedData);
        // Save the completed pin to local storage
        _storageService.savePin(pin);
        debugPrint("Successfully reassembled, decrypted, and saved pin $uuid.");
      } catch (e) {
        debugPrint("Failed to decrypt or save pin $uuid. Error: $e");
      } finally {
        // Clean up memory for this message transfer
        _incomingDataChunks.remove(uuid);
        _expectedDataLengths.remove(uuid);
        _incomingHeaders.remove(uuid);
      }
    }
  }

  @override
  void dispose() {
    _meshManagerApi.dispose();
    super.dispose();
  }
}
