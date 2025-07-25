// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_pin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoicePinAdapter extends TypeAdapter<VoicePin> {
  @override
  final int typeId = 0;

  @override
  VoicePin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoicePin(
      uuid: fields[0] as String,
      parentThreadId: fields[1] as String?,
      encryptedAudioData: fields[2] as Uint8List,
      timestamp: fields[3] as DateTime,
      authorSessionId: fields[4] as String,
      latitude: fields[5] as double?,
      longitude: fields[6] as double?,
      sentimentTag: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VoicePin obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.parentThreadId)
      ..writeByte(2)
      ..write(obj.encryptedAudioData)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.authorSessionId)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.sentimentTag);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoicePinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
