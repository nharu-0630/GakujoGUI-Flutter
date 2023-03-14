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
      weekday: fields[0] as int,
      period: fields[1] as int,
      subject: fields[2] as String,
      id: fields[3] as String,
      teacher: fields[4] as String,
      subjectSection: fields[5] as String,
      selectionSection: fields[6] as String,
      credit: fields[7] as int,
      className: fields[8] as String,
      classRoom: fields[9] as String,
      kamokuCode: fields[10] as String,
      classCode: fields[11] as String,
      syllabusSubject: fields[12] as String,
      syllabusTeacher: fields[13] as String,
      syllabusAffiliation: fields[14] as String,
      syllabusResearchRoom: fields[15] as String,
      syllabusSharingTeacher: fields[16] as String,
      syllabusClassName: fields[17] as String,
      syllabusSemesterName: fields[18] as String,
      syllabusSelectionSection: fields[19] as String,
      syllabusTargetGrade: fields[20] as String,
      syllabusCredit: fields[21] as String,
      syllabusWeekdayPeriod: fields[22] as String,
      syllabusClassRoom: fields[23] as String,
      syllabusKeyword: fields[24] as String,
      syllabusClassTarget: fields[25] as String,
      syllabusLearningDetail: fields[26] as String,
      syllabusClassPlan: fields[27] as String,
      syllabusClassRequirement: fields[28] as String,
      syllabusTextbook: fields[29] as String,
      syllabusReferenceBook: fields[30] as String,
      syllabusPreparationReview: fields[31] as String,
      syllabusEvaluationMethod: fields[32] as String,
      syllabusOfficeHour: fields[33] as String,
      syllabusMessage: fields[34] as String,
      syllabusActiveLearning: fields[35] as String,
      syllabusTeacherPracticalExperience: fields[36] as String,
      syllabusTeacherCareerClassDetail: fields[37] as String,
      syllabusTeachingProfessionSection: fields[38] as String,
      syllabusRelatedClassSubjects: fields[39] as String,
      syllabusOther: fields[40] as String,
      syllabusHomeClassStyle: fields[41] as String,
      syllabusHomeClassStyleDetail: fields[42] as String,
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
