// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedFileAdapter extends TypeAdapter<SharedFile> {
  @override
  final int typeId = 7;

  @override
  SharedFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedFile(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      (fields[3] as List?)?.cast<String>(),
      fields[4] as String,
      fields[5] as String,
      fields[6] as DateTime,
      isAcquired: fields[7] as bool,
      isArchived: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SharedFile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.fileSize)
      ..writeByte(3)
      ..write(obj.fileNames)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.publicPeriod)
      ..writeByte(6)
      ..write(obj.updateDateTime)
      ..writeByte(7)
      ..write(obj.isAcquired)
      ..writeByte(8)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
