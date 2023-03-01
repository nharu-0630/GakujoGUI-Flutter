// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableAdapter extends TypeAdapter<Timetable> {
  @override
  final int typeId = 9;

  @override
  Timetable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Timetable(
      fields[0] as int,
      fields[1] as int,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as int,
      fields[8] as String,
      fields[9] as String,
      fields[10] as String,
      fields[11] as String,
      fields[12] as String,
      fields[13] as String,
      fields[14] as String,
      fields[15] as String,
      fields[16] as String,
      fields[17] as String,
      fields[18] as String,
      fields[19] as String,
      fields[20] as String,
      fields[21] as String,
      fields[22] as String,
      fields[23] as String,
      fields[24] as String,
      fields[25] as String,
      fields[26] as String,
      fields[27] as String,
      fields[28] as String,
      fields[29] as String,
      fields[30] as String,
      fields[31] as String,
      fields[32] as String,
      fields[33] as String,
      fields[34] as String,
      fields[35] as String,
      fields[36] as String,
      fields[37] as String,
      fields[38] as String,
      fields[39] as String,
      fields[40] as String,
      fields[41] as String,
      fields[42] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Timetable obj) {
    writer
      ..writeByte(43)
      ..writeByte(0)
      ..write(obj.weekday)
      ..writeByte(1)
      ..write(obj.period)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.teacher)
      ..writeByte(5)
      ..write(obj.subjectSection)
      ..writeByte(6)
      ..write(obj.selectionSection)
      ..writeByte(7)
      ..write(obj.credit)
      ..writeByte(8)
      ..write(obj.className)
      ..writeByte(9)
      ..write(obj.classRoom)
      ..writeByte(10)
      ..write(obj.kamokuCode)
      ..writeByte(11)
      ..write(obj.classCode)
      ..writeByte(12)
      ..write(obj.syllabusSubject)
      ..writeByte(13)
      ..write(obj.syllabusTeacher)
      ..writeByte(14)
      ..write(obj.syllabusAffiliation)
      ..writeByte(15)
      ..write(obj.syllabusResearchRoom)
      ..writeByte(16)
      ..write(obj.syllabusSharingTeacher)
      ..writeByte(17)
      ..write(obj.syllabusClassName)
      ..writeByte(18)
      ..write(obj.syllabusSemesterName)
      ..writeByte(19)
      ..write(obj.syllabusSelectionSection)
      ..writeByte(20)
      ..write(obj.syllabusTargetGrade)
      ..writeByte(21)
      ..write(obj.syllabusCredit)
      ..writeByte(22)
      ..write(obj.syllabusWeekdayPeriod)
      ..writeByte(23)
      ..write(obj.syllabusClassRoom)
      ..writeByte(24)
      ..write(obj.syllabusKeyword)
      ..writeByte(25)
      ..write(obj.syllabusClassTarget)
      ..writeByte(26)
      ..write(obj.syllabusLearningDetail)
      ..writeByte(27)
      ..write(obj.syllabusClassPlan)
      ..writeByte(28)
      ..write(obj.syllabusClassRequirement)
      ..writeByte(29)
      ..write(obj.syllabusTextbook)
      ..writeByte(30)
      ..write(obj.syllabusReferenceBook)
      ..writeByte(31)
      ..write(obj.syllabusPreparationReview)
      ..writeByte(32)
      ..write(obj.syllabusEvaluationMethod)
      ..writeByte(33)
      ..write(obj.syllabusOfficeHour)
      ..writeByte(34)
      ..write(obj.syllabusMessage)
      ..writeByte(35)
      ..write(obj.syllabusActiveLearning)
      ..writeByte(36)
      ..write(obj.syllabusTeacherPracticalExperience)
      ..writeByte(37)
      ..write(obj.syllabusTeacherCareerClassDetail)
      ..writeByte(38)
      ..write(obj.syllabusTeachingProfessionSection)
      ..writeByte(39)
      ..write(obj.syllabusRelatedClassSubjects)
      ..writeByte(40)
      ..write(obj.syllabusOther)
      ..writeByte(41)
      ..write(obj.syllabusHomeClassStyle)
      ..writeByte(42)
      ..write(obj.syllabusHomeClassStyleDetail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
