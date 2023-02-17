// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizAdapter extends TypeAdapter<Quiz> {
  @override
  final int typeId = 5;

  @override
  Quiz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quiz(
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
      fields[11] as String,
      fields[12] as int,
      fields[13] as String,
      fields[14] as String,
      (fields[15] as List?)?.cast<String>(),
      fields[16] as String,
      isAcquired: fields[17] as bool,
      isArchived: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Quiz obj) {
    writer
      ..writeByte(19)
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
      ..write(obj.submissionStatus)
      ..writeByte(10)
      ..write(obj.implementationFormat)
      ..writeByte(11)
      ..write(obj.operation)
      ..writeByte(12)
      ..write(obj.questionsCount)
      ..writeByte(13)
      ..write(obj.evaluationMethod)
      ..writeByte(14)
      ..write(obj.description)
      ..writeByte(15)
      ..write(obj.fileNames)
      ..writeByte(16)
      ..write(obj.message)
      ..writeByte(17)
      ..write(obj.isAcquired)
      ..writeByte(18)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
