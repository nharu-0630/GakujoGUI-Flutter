// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_link.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassLinkAdapter extends TypeAdapter<ClassLink> {
  @override
  final int typeId = 8;

  @override
  ClassLink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassLink(
      subject: fields[0] as String,
      title: fields[1] as String,
      id: fields[2] as String,
      comment: fields[3] as String,
      link: fields[4] as String,
      isAcquired: fields[5] as bool,
      isArchived: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ClassLink obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.comment)
      ..writeByte(4)
      ..write(obj.link)
      ..writeByte(5)
      ..write(obj.isAcquired)
      ..writeByte(6)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassLinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
