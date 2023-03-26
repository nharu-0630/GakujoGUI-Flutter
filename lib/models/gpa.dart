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

  Gpa({
    required this.evaluationCredits,
    required this.facultyGrade,
    required this.facultyGpa,
    required this.facultyGpas,
    required this.facultyCalculationDate,
    required this.facultyImage,
    required this.departmentGrade,
    required this.departmentGpa,
    required this.departmentGpas,
    required this.departmentCalculationDate,
    required this.departmentRankNumber,
    required this.departmentRankDenom,
    required this.courseRankNumber,
    required this.courseRankDenom,
    required this.departmentImage,
    required this.yearCredits,
  });

  Gpa.init()
      : this(
          evaluationCredits: {},
          facultyGrade: '',
          facultyGpa: 0.0,
          facultyGpas: {},
          facultyCalculationDate: DateTime.fromMicrosecondsSinceEpoch(0),
          facultyImage: null,
          departmentGrade: '',
          departmentGpa: 0.0,
          departmentGpas: {},
          departmentCalculationDate: DateTime.fromMicrosecondsSinceEpoch(0),
          departmentRankNumber: 0,
          departmentRankDenom: 0,
          courseRankNumber: 0,
          courseRankDenom: 0,
          departmentImage: null,
          yearCredits: {},
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
  late GpaBox _box;

  GpaRepository(GpaBox box) {
    _box = box;
  }

  Future<void> save(Gpa gpa) async {
    await _box.open();
    Box b = await _box.box;
    await b.put('gpa', gpa);
    notifyListeners();
  }

  Future<Gpa> load() async {
    await _box.open();
    Box b = await _box.box;
    return b.get('gpa') ?? Gpa.init();
  }

  Future<void> delete() async {
    await _box.open();
    Box b = await _box.box;
    await b.put('gpa', Gpa.init());
    notifyListeners();
  }
}
