import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:hive/hive.dart';

part 'timetable.g.dart';

@HiveType(typeId: 9)
class Timetable implements Comparable<Timetable> {
  @HiveField(0)
  int weekday;
  @HiveField(1)
  int period;

  @HiveField(2)
  String subject;
  @HiveField(3)
  String id;
  @HiveField(4)
  String teacher;
  @HiveField(5)
  String subjectSection;
  @HiveField(6)
  String selectionSection;
  @HiveField(7)
  int credit;
  @HiveField(8)
  String className;
  @HiveField(9)
  String classRoom;
  @HiveField(10)
  String kamokuCode;
  @HiveField(11)
  String classCode;

  @HiveField(12)
  String syllabusSubject;
  @HiveField(13)
  String syllabusTeacher;
  @HiveField(14)
  String syllabusAffiliation;
  @HiveField(15)
  String syllabusResearchRoom;
  @HiveField(16)
  String syllabusSharingTeacher;
  @HiveField(17)
  String syllabusClassName;
  @HiveField(18)
  String syllabusSemesterName;
  @HiveField(19)
  String syllabusSelectionSection;
  @HiveField(20)
  String syllabusTargetGrade;
  @HiveField(21)
  String syllabusCredit;
  @HiveField(22)
  String syllabusWeekdayPeriod;
  @HiveField(23)
  String syllabusClassRoom;
  @HiveField(24)
  String syllabusKeyword;
  @HiveField(25)
  String syllabusClassTarget;
  @HiveField(26)
  String syllabusLearningDetail;
  @HiveField(27)
  String syllabusClassPlan;
  @HiveField(28)
  String syllabusClassRequirement;
  @HiveField(29)
  String syllabusTextbook;
  @HiveField(30)
  String syllabusReferenceBook;
  @HiveField(31)
  String syllabusPreparationReview;
  @HiveField(32)
  String syllabusEvaluationMethod;
  @HiveField(33)
  String syllabusOfficeHour;
  @HiveField(34)
  String syllabusMessage;
  @HiveField(35)
  String syllabusActiveLearning;
  @HiveField(36)
  String syllabusTeacherPracticalExperience;
  @HiveField(37)
  String syllabusTeacherCareerClassDetail;
  @HiveField(38)
  String syllabusTeachingProfessionSection;
  @HiveField(39)
  String syllabusRelatedClassSubjects;
  @HiveField(40)
  String syllabusOther;
  @HiveField(41)
  String syllabusHomeClassStyle;
  @HiveField(42)
  String syllabusHomeClassStyleDetail;

  Timetable(
    this.weekday,
    this.period,
    this.subject,
    this.id,
    this.teacher,
    this.subjectSection,
    this.selectionSection,
    this.credit,
    this.className,
    this.classRoom,
    this.kamokuCode,
    this.classCode,
    this.syllabusSubject,
    this.syllabusTeacher,
    this.syllabusAffiliation,
    this.syllabusResearchRoom,
    this.syllabusSharingTeacher,
    this.syllabusClassName,
    this.syllabusSemesterName,
    this.syllabusSelectionSection,
    this.syllabusTargetGrade,
    this.syllabusCredit,
    this.syllabusWeekdayPeriod,
    this.syllabusClassRoom,
    this.syllabusKeyword,
    this.syllabusClassTarget,
    this.syllabusLearningDetail,
    this.syllabusClassPlan,
    this.syllabusClassRequirement,
    this.syllabusTextbook,
    this.syllabusReferenceBook,
    this.syllabusPreparationReview,
    this.syllabusEvaluationMethod,
    this.syllabusOfficeHour,
    this.syllabusMessage,
    this.syllabusActiveLearning,
    this.syllabusTeacherPracticalExperience,
    this.syllabusTeacherCareerClassDetail,
    this.syllabusTeachingProfessionSection,
    this.syllabusRelatedClassSubjects,
    this.syllabusOther,
    this.syllabusHomeClassStyle,
    this.syllabusHomeClassStyleDetail,
  );

  // factory TimeTable.fromElement(Element element) {
  //   var subject =
  //       element.querySelectorAll('td')[1].text.trimWhiteSpace().trimSubject();
  //   var title =
  //       element.querySelectorAll('td')[2].querySelector('a')!.text.trim();
  //   var comment = element.querySelectorAll('td')[3].text.trim();
  //   var id = element
  //       .querySelectorAll('td')[2]
  //       .querySelector('a')!
  //       .attributes['onclick']!
  //       .trimJsArgs(0)
  //       .replaceAll('javascript:moveToDetail', '');
  //   return TimeTable();
  // }

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      kamokuCode.toLowerCase().contains(value.toLowerCase()) ||
      classCode.toLowerCase().contains(value.toLowerCase());

  @override
  String toString() => '$subject $className';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Timetable) {
      return kamokuCode == other.kamokuCode && classCode == other.classCode;
    }
    return false;
  }

  @override
  int get hashCode => kamokuCode.hashCode ^ classCode.hashCode;

  @override
  int compareTo(Timetable other) {
    var compare1 = kamokuCode.compareTo(other.kamokuCode);
    if (compare1 != 0) {
      return compare1;
    }
    var compare2 = classCode.compareTo(other.classCode);
    return compare2;
  }
}

class TimetableBox {
  Future<Box> box = Hive.openBox<Timetable>('time_table');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Timetable>('time_table');
    }
  }
}

class TimetableRepository extends ChangeNotifier {
  late TimetableBox _timetableBox;

  TimetableRepository(TimetableBox timetableBox) {
    _timetableBox = timetableBox;
  }

  Future<void> add(Timetable timetable, {bool overwrite = false}) async {
    var box = await _timetableBox.box;
    if (!overwrite && box.containsKey(timetable.hashCode.toString())) return;
    await box.put(timetable.hashCode.toString(), timetable);
    notifyListeners();
  }

  Future<void> addAll(List<Timetable> timetables,
      {bool overwrite = false}) async {
    for (var timetable in timetables) {
      await add(timetable, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(Timetable timetable) async {
    var box = await _timetableBox.box;
    await box.delete(timetable.hashCode.toString());
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _timetableBox.box;
    await box.deleteFromDisk();
    await _timetableBox.open();
    notifyListeners();
  }

  Future<Timetable?> get(int key) async {
    var box = await _timetableBox.box;
    return box.get(key);
  }

  Future<List<Timetable>> getAll() async {
    var box = await _timetableBox.box;
    return box.values.toList().cast<Timetable>();
  }
}
