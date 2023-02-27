// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 1;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      (fields[5] as List?)?.cast<String>(),
      fields[6] as String?,
      fields[7] as String?,
      fields[8] as String?,
      fields[9] as DateTime,
      fields[10] as DateTime,
      fields[11] as String?,
      isAcquired: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.teacherName)
      ..writeByte(2)
      ..write(obj.contactType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.fileNames)
      ..writeByte(6)
      ..write(obj.fileLinkRelease)
      ..writeByte(7)
      ..write(obj.referenceUrl)
      ..writeByte(8)
      ..write(obj.severity)
      ..writeByte(9)
      ..write(obj.targetDateTime)
      ..writeByte(10)
      ..write(obj.contactDateTime)
      ..writeByte(11)
      ..write(obj.webReplyRequest)
      ..writeByte(12)
      ..write(obj.isAcquired);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
