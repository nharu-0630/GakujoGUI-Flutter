// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 3;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      username: fields[0] as String?,
      password: fields[1] as String?,
      year: fields[2] as int?,
      semester: fields[3] as int?,
      fullName: fields[4] as String?,
      profileImage: fields[5] as String?,
      lastLoginTime: fields[6] as DateTime,
      accessEnvironmentName: fields[7] as String?,
      accessEnvironmentKey: fields[8] as String?,
      accessEnvironmentValue: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.semester)
      ..writeByte(4)
      ..write(obj.fullName)
      ..writeByte(5)
      ..write(obj.profileImage)
      ..writeByte(6)
      ..write(obj.lastLoginTime)
      ..writeByte(7)
      ..write(obj.accessEnvironmentName)
      ..writeByte(8)
      ..write(obj.accessEnvironmentKey)
      ..writeByte(9)
      ..write(obj.accessEnvironmentValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
