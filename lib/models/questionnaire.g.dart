// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionnaireAdapter extends TypeAdapter<Questionnaire> {
  @override
  final int typeId = 12;

  @override
  Questionnaire read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Questionnaire(
      subject: fields[0] as String,
      title: fields[1] as String,
      id: fields[2] as String,
      schoolYear: fields[3] as String,
      subjectCode: fields[4] as String,
      classCode: fields[5] as String,
      status: fields[6] as String,
      startDateTime: fields[7] as DateTime,
      endDateTime: fields[8] as DateTime,
      operation: fields[9] as String,
      questionsCount: fields[10] as int,
      submitterName: fields[11] as String,
      description: fields[12] as String,
      fileNames: (fields[13] as List?)?.cast<String>(),
      message: fields[14] as String,
      isAcquired: fields[15] as bool,
      isArchived: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Questionnaire obj) {
    writer
      ..writeByte(17)
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
      ..write(obj.operation)
      ..writeByte(10)
      ..write(obj.questionsCount)
      ..writeByte(11)
      ..write(obj.submitterName)
      ..writeByte(12)
      ..write(obj.description)
      ..writeByte(13)
      ..write(obj.fileNames)
      ..writeByte(14)
      ..write(obj.message)
      ..writeByte(15)
      ..write(obj.isAcquired)
      ..writeByte(16)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionnaireAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
