// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GpaAdapter extends TypeAdapter<Gpa> {
  @override
  final int typeId = 10;

  @override
  Gpa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gpa(
      (fields[0] as Map).cast<String, dynamic>(),
      fields[1] as String,
      fields[2] as double,
      (fields[3] as Map).cast<String, double>(),
      fields[4] as DateTime,
      fields[5] as String?,
      fields[6] as String,
      fields[7] as double,
      (fields[8] as Map).cast<String, double>(),
      fields[9] as DateTime,
      fields[10] as int,
      fields[11] as int,
      fields[12] as int,
      fields[13] as int,
      fields[14] as String?,
      (fields[15] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Gpa obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.evaluationCredits)
      ..writeByte(1)
      ..write(obj.facultyGrade)
      ..writeByte(2)
      ..write(obj.facultyGpa)
      ..writeByte(3)
      ..write(obj.facultyGpas)
      ..writeByte(4)
      ..write(obj.facultyCalculationDate)
      ..writeByte(5)
      ..write(obj.facultyImage)
      ..writeByte(6)
      ..write(obj.departmentGrade)
      ..writeByte(7)
      ..write(obj.departmentGpa)
      ..writeByte(8)
      ..write(obj.departmentGpas)
      ..writeByte(9)
      ..write(obj.departmentCalculationDate)
      ..writeByte(10)
      ..write(obj.departmentRankNumber)
      ..writeByte(11)
      ..write(obj.departmentRankDenom)
      ..writeByte(12)
      ..write(obj.courseRankNumber)
      ..writeByte(13)
      ..write(obj.courseRankDenom)
      ..writeByte(14)
      ..write(obj.departmentImage)
      ..writeByte(15)
      ..write(obj.yearCredits);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GpaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
