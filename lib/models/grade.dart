import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'grade.g.dart';

@HiveType(typeId: 6)
class Grade implements Comparable<Grade> {
  @HiveField(0)
  String subjectsName;
  @HiveField(1)
  String teacherName;
  @HiveField(2)
  String subjectsSection;
  @HiveField(3)
  int credit;
  @HiveField(4)
  String evaluation;
  @HiveField(5)
  double? score;
  @HiveField(6)
  double? gp;
  @HiveField(7)
  String acquisitionYear;
  @HiveField(8)
  DateTime reportDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  @HiveField(9)
  String testType;

  Grade(
    this.subjectsName,
    this.teacherName,
    this.subjectsSection,
    this.credit,
    this.evaluation,
    this.score,
    this.gp,
    this.acquisitionYear,
    this.reportDateTime,
    this.testType,
  );

  factory Grade.fromElement(Element element) {
    return Grade(
      element.querySelectorAll('td')[0].text.trim(),
      element.querySelectorAll('td')[1].text.trim(),
      element.querySelectorAll('td')[2].text.trim(),
      int.parse(element.querySelectorAll('td')[3].text.trim()),
      element.querySelectorAll('td')[4].text.trim(),
      double.tryParse(element.querySelectorAll('td')[5].text.trim()),
      double.tryParse(element.querySelectorAll('td')[6].text.trim()),
      element.querySelectorAll('td')[7].text.trim(),
      DateTime.parse(element.querySelectorAll('td')[8].text.trim()),
      element.querySelectorAll('td')[9].text.trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Grade) {
      return subjectsName == other.subjectsName &&
          acquisitionYear == other.acquisitionYear;
    }
    return false;
  }

  @override
  int get hashCode => subjectsName.hashCode ^ acquisitionYear.hashCode;

  @override
  int compareTo(Grade other) {
    var compare1 = reportDateTime.compareTo(other.reportDateTime);
    if (compare1 != 0) {
      return compare1;
    }
    var compare2 = acquisitionYear.compareTo(other.acquisitionYear);
    if (compare2 != 0) {
      return compare2;
    }
    var compare3 = subjectsName.compareTo(other.subjectsName);
    return compare3;
  }
}

class GradeBox {
  Future<Box> box = Hive.openBox<GradeBox>('grade');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Grade>('grade');
    }
  }
}

class GradeRepository extends ChangeNotifier {
  late GradeBox _gradeBox;

  GradeRepository(GradeBox gradeBox) {
    _gradeBox = gradeBox;
  }

  Future<void> add(Grade grade, {bool overwrite = false}) async {
    var box = await _gradeBox.box;
    if (!overwrite && box.containsKey(grade.hashCode)) return;
    await box.put(grade.hashCode, grade);
    notifyListeners();
  }

  Future<void> addAll(List<Grade> grades) async {
    var box = await _gradeBox.box;
    for (var subject in grades) {
      await box.put(subject.hashCode, subject);
    }
    notifyListeners();
  }

  Future<void> delete(Grade grade) async {
    var box = await _gradeBox.box;
    await box.delete(grade.hashCode);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _gradeBox.box;
    await box.deleteFromDisk();
    await _gradeBox.open();
    notifyListeners();
  }

  Future<List<Grade>> getAll() async {
    var box = await _gradeBox.box;
    return box.values.toList().cast<Grade>();
  }
}
