// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 6;

  @override
  Grade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grade(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as int,
      fields[4] as String,
      fields[5] as double?,
      fields[6] as double?,
      fields[7] as String,
      fields[8] as DateTime,
      fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.subjectsName)
      ..writeByte(1)
      ..write(obj.teacherName)
      ..writeByte(2)
      ..write(obj.subjectsSection)
      ..writeByte(3)
      ..write(obj.credit)
      ..writeByte(4)
      ..write(obj.evaluation)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.gp)
      ..writeByte(7)
      ..write(obj.acquisitionYear)
      ..writeByte(8)
      ..write(obj.reportDateTime)
      ..writeByte(9)
      ..write(obj.testType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
