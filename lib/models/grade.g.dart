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
      fields[3] as String,
      fields[4] as int,
      fields[5] as String,
      fields[6] as double?,
      fields[7] as double?,
      fields[8] as String,
      fields[9] as DateTime,
      fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.subjectsName)
      ..writeByte(1)
      ..write(obj.teacherName)
      ..writeByte(2)
      ..write(obj.subjectsSection)
      ..writeByte(3)
      ..write(obj.selectionSection)
      ..writeByte(4)
      ..write(obj.credit)
      ..writeByte(5)
      ..write(obj.evaluation)
      ..writeByte(6)
      ..write(obj.score)
      ..writeByte(7)
      ..write(obj.gp)
      ..writeByte(8)
      ..write(obj.acquisitionYear)
      ..writeByte(9)
      ..write(obj.reportDateTime)
      ..writeByte(10)
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
