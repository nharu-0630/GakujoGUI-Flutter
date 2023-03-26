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

  Timetable({
    required this.weekday,
    required this.period,
    required this.subject,
    required this.id,
    required this.teacher,
    required this.subjectSection,
    required this.selectionSection,
    required this.credit,
    required this.className,
    required this.classRoom,
    required this.kamokuCode,
    required this.classCode,
    required this.syllabusSubject,
    required this.syllabusTeacher,
    required this.syllabusAffiliation,
    required this.syllabusResearchRoom,
    required this.syllabusSharingTeacher,
    required this.syllabusClassName,
    required this.syllabusSemesterName,
    required this.syllabusSelectionSection,
    required this.syllabusTargetGrade,
    required this.syllabusCredit,
    required this.syllabusWeekdayPeriod,
    required this.syllabusClassRoom,
    required this.syllabusKeyword,
    required this.syllabusClassTarget,
    required this.syllabusLearningDetail,
    required this.syllabusClassPlan,
    required this.syllabusClassRequirement,
    required this.syllabusTextbook,
    required this.syllabusReferenceBook,
    required this.syllabusPreparationReview,
    required this.syllabusEvaluationMethod,
    required this.syllabusOfficeHour,
    required this.syllabusMessage,
    required this.syllabusActiveLearning,
    required this.syllabusTeacherPracticalExperience,
    required this.syllabusTeacherCareerClassDetail,
    required this.syllabusTeachingProfessionSection,
    required this.syllabusRelatedClassSubjects,
    required this.syllabusOther,
    required this.syllabusHomeClassStyle,
    required this.syllabusHomeClassStyleDetail,
  });

  Timetable.init()
      : this(
          weekday: 0,
          period: 0,
          subject: '',
          id: '',
          teacher: '',
          subjectSection: '',
          selectionSection: '',
          credit: 0,
          className: '',
          classRoom: '',
          kamokuCode: '',
          classCode: '',
          syllabusSubject: '',
          syllabusTeacher: '',
          syllabusAffiliation: '',
          syllabusResearchRoom: '',
          syllabusSharingTeacher: '',
          syllabusClassName: '',
          syllabusSemesterName: '',
          syllabusSelectionSection: '',
          syllabusTargetGrade: '',
          syllabusCredit: '',
          syllabusWeekdayPeriod: '',
          syllabusClassRoom: '',
          syllabusKeyword: '',
          syllabusClassTarget: '',
          syllabusLearningDetail: '',
          syllabusClassPlan: '',
          syllabusClassRequirement: '',
          syllabusTextbook: '',
          syllabusReferenceBook: '',
          syllabusPreparationReview: '',
          syllabusEvaluationMethod: '',
          syllabusOfficeHour: '',
          syllabusMessage: '',
          syllabusActiveLearning: '',
          syllabusTeacherPracticalExperience: '',
          syllabusTeacherCareerClassDetail: '',
          syllabusTeachingProfessionSection: '',
          syllabusRelatedClassSubjects: '',
          syllabusOther: '',
          syllabusHomeClassStyle: '',
          syllabusHomeClassStyleDetail: '',
        );

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      kamokuCode.toLowerCase().contains(value.toLowerCase()) ||
      classCode.toLowerCase().contains(value.toLowerCase());

  @override
  String toString() => '$subject $className';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
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
    if (compare1 != 0) return compare1;
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
  late TimetableBox _box;

  TimetableRepository(TimetableBox box) {
    _box = box;
  }

  Future<void> add(Timetable timetable, {bool overwrite = false}) async {
    var box = await _box.box;
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
    var box = await _box.box;
    await box.delete(timetable.hashCode.toString());
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _box.box;
    await box.deleteFromDisk();
    await _box.open();
    notifyListeners();
  }

  Future<Timetable?> get(int key) async {
    var box = await _box.box;
    return box.get(key);
  }

  Future<List<Timetable>> getAll() async {
    var box = await _box.box;
    return box.values.toList().cast<Timetable>();
  }
}
