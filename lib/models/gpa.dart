import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'gpa.g.dart';

@HiveType(typeId: 10)
class Gpa {
  @HiveField(0)
  Map<String, dynamic> evaluationCredits;
  @HiveField(1)
  String facultyGrade;
  @HiveField(2)
  double facultyGpa;
  @HiveField(3)
  Map<String, double> facultyGpas;
  @HiveField(4)
  DateTime facultyCalculationDate;
  @HiveField(5)
  String? facultyImage;
  @HiveField(6)
  String departmentGrade;
  @HiveField(7)
  double departmentGpa;
  @HiveField(8)
  Map<String, double> departmentGpas;
  @HiveField(9)
  DateTime departmentCalculationDate;
  @HiveField(10)
  int departmentRankNumber;
  @HiveField(11)
  int departmentRankDenom;
  @HiveField(12)
  int courseRankNumber;
  @HiveField(13)
  int courseRankDenom;
  @HiveField(14)
  String? departmentImage;
  @HiveField(15)
  Map<String, dynamic> yearCredits;

  Gpa(
    this.evaluationCredits,
    this.facultyGrade,
    this.facultyGpa,
    this.facultyGpas,
    this.facultyCalculationDate,
    this.facultyImage,
    this.departmentGrade,
    this.departmentGpa,
    this.departmentGpas,
    this.departmentCalculationDate,
    this.departmentRankNumber,
    this.departmentRankDenom,
    this.courseRankNumber,
    this.courseRankDenom,
    this.departmentImage,
    this.yearCredits,
  );
}

class GpaBox {
  Future<Box> box = Hive.openBox<Gpa>('gpa');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Gpa>('gpa');
    }
  }
}

class GpaRepository extends ChangeNotifier {
  late GpaBox _gpaBox;

  GpaRepository(GpaBox gpaBox) {
    _gpaBox = gpaBox;
  }

  Future<void> save(Gpa gpa) async {
    await _gpaBox.open();
    Box b = await _gpaBox.box;
    await b.put('gpa', gpa);
    notifyListeners();
  }

  Future<Gpa> load() async {
    await _gpaBox.open();
    Box b = await _gpaBox.box;
    return b.get('gpa') ??
        Gpa(
            {},
            '',
            0.0,
            {},
            DateTime.fromMicrosecondsSinceEpoch(0),
            null,
            '',
            0.0,
            {},
            DateTime.fromMicrosecondsSinceEpoch(0),
            0,
            0,
            0,
            0,
            null,
            {});
  }

  Future<void> delete() async {
    await _gpaBox.open();
    Box b = await _gpaBox.box;
    await b.put(
        'gpa',
        Gpa(
            {},
            '',
            0.0,
            {},
            DateTime.fromMicrosecondsSinceEpoch(0),
            null,
            '',
            0.0,
            {},
            DateTime.fromMicrosecondsSinceEpoch(0),
            0,
            0,
            0,
            0,
            null,
            {}));
    notifyListeners();
  }
}
