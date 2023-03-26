// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'syllabus_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyllabusResultAdapter extends TypeAdapter<SyllabusResult> {
  @override
  final int typeId = 11;

  @override
  SyllabusResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyllabusResult(
      subjectId: fields[0] as String,
      formatCode: fields[1] as String,
      rowIndex: fields[2] as String,
      jikanwariSchoolYear: fields[3] as String,
      titleName: fields[4] as String,
      indexName: fields[5] as String,
      subjectCode: fields[6] as String,
      numberingCode: fields[7] as String,
      subjectName: fields[8] as String,
      language: fields[9] as String,
      teacherName: fields[10] as String,
      className: fields[11] as String,
      halfTimeInfo: fields[12] as String,
      youbiJigen: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusResult obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.subjectId)
      ..writeByte(1)
      ..write(obj.formatCode)
      ..writeByte(2)
      ..write(obj.rowIndex)
      ..writeByte(3)
      ..write(obj.jikanwariSchoolYear)
      ..writeByte(4)
      ..write(obj.titleName)
      ..writeByte(5)
      ..write(obj.indexName)
      ..writeByte(6)
      ..write(obj.subjectCode)
      ..writeByte(7)
      ..write(obj.numberingCode)
      ..writeByte(8)
      ..write(obj.subjectName)
      ..writeByte(9)
      ..write(obj.language)
      ..writeByte(10)
      ..write(obj.teacherName)
      ..writeByte(11)
      ..write(obj.className)
      ..writeByte(12)
      ..write(obj.halfTimeInfo)
      ..writeByte(13)
      ..write(obj.youbiJigen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllabusResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
