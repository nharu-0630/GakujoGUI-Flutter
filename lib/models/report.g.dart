// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 4;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Report(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as DateTime,
      fields[8] as DateTime,
      fields[9] as String,
      fields[10] as String,
      fields[11] as DateTime,
      fields[12] as String,
      fields[13] as String,
      (fields[14] as List?)?.cast<String>(),
      fields[15] as String,
      isAcquired: fields[16] as bool,
      isArchived: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.schoolYear)
      ..writeByte(4)
      ..write(obj.subjectCode)
      ..writeByte(5)
      ..write(obj.classCode)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.startDateTime)
      ..writeByte(8)
      ..write(obj.endDateTime)
      ..writeByte(9)
      ..write(obj.implementationFormat)
      ..writeByte(10)
      ..write(obj.operation)
      ..writeByte(11)
      ..write(obj.submittedDateTime)
      ..writeByte(12)
      ..write(obj.evaluationMethod)
      ..writeByte(13)
      ..write(obj.description)
      ..writeByte(14)
      ..write(obj.fileNames)
      ..writeByte(15)
      ..write(obj.message)
      ..writeByte(16)
      ..write(obj.isAcquired)
      ..writeByte(17)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
