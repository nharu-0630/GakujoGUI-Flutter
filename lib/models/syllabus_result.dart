import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_gui/api/parse.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'syllabus_result.g.dart';

@HiveType(typeId: 11)
class SyllabusResult implements Comparable<SyllabusResult> {
  @HiveField(0)
  String subjectId;
  @HiveField(1)
  String formatCode;
  @HiveField(2)
  String rowIndex;
  @HiveField(3)
  String jikanwariSchoolYear;
  @HiveField(4)
  String titleName;
  @HiveField(5)
  String indexName;
  @HiveField(6)
  String subjectCode;
  @HiveField(7)
  String numberingCode;
  @HiveField(8)
  String subjectName;
  @HiveField(9)
  String language;
  @HiveField(10)
  String teacherName;
  @HiveField(11)
  String className;
  @HiveField(12)
  String halfTimeInfo;
  @HiveField(13)
  String youbiJigen;

  SyllabusResult({
    required this.subjectId,
    required this.formatCode,
    required this.rowIndex,
    required this.jikanwariSchoolYear,
    required this.titleName,
    required this.indexName,
    required this.subjectCode,
    required this.numberingCode,
    required this.subjectName,
    required this.language,
    required this.teacherName,
    required this.className,
    required this.halfTimeInfo,
    required this.youbiJigen,
  });

  factory SyllabusResult.fromElement(Element element) {
    return SyllabusResult(
      subjectId: RegExp(r'(?<=subjectId=)\d*').firstMatch(
          element.querySelectorAll('td')[0].attributes['onclick']!)![0]!,
      formatCode: RegExp(r'(?<=formatCode=)\d*').firstMatch(
          element.querySelectorAll('td')[0].attributes['onclick']!)![0]!,
      rowIndex: RegExp(r'(?<=rowIndex=)\d*').firstMatch(
          element.querySelectorAll('td')[0].attributes['onclick']!)![0]!,
      jikanwariSchoolYear: RegExp(r'(?<=jikanwariSchoolYear=)\d*').firstMatch(
          element.querySelectorAll('td')[0].attributes['onclick']!)![0]!,
      titleName: element.querySelectorAll('td')[0].text.trimWhiteSpace(),
      indexName: element.querySelectorAll('td')[1].text.trimWhiteSpace(),
      subjectCode: element.querySelectorAll('td')[2].text.trimWhiteSpace(),
      numberingCode: element.querySelectorAll('td')[3].text.trimWhiteSpace(),
      subjectName: element.querySelectorAll('td')[4].text.trimWhiteSpace(),
      language: element.querySelectorAll('td')[5].text.trimWhiteSpace(),
      teacherName: element.querySelectorAll('td')[6].text.trimWhiteSpace(),
      className: element.querySelectorAll('td')[7].text.trimWhiteSpace(),
      halfTimeInfo: element.querySelectorAll('td')[8].text.trimWhiteSpace(),
      youbiJigen: element.querySelectorAll('td')[9].text.trimWhiteSpace(),
    );
  }

  @override
  String toString() => subjectName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is SyllabusResult) {
      return subjectId == other.subjectId &&
          formatCode == other.formatCode &&
          rowIndex == other.rowIndex &&
          jikanwariSchoolYear == other.jikanwariSchoolYear;
    }
    return false;
  }

  @override
  int get hashCode =>
      subjectId.hashCode ^
      formatCode.hashCode ^
      rowIndex.hashCode ^
      jikanwariSchoolYear.hashCode;

  @override
  int compareTo(SyllabusResult other) => subjectId.compareTo(other.subjectId);
}

class SyllabusResultBox {
  Future<Box> box = Hive.openBox<SyllabusResult>('syllabus_result');

  Future<void> open() async {
    Box b = await box;
    if (b.isOpen) {
      box = Hive.openBox<SyllabusResult>('syllabus_result');
    }
  }
}

class SyllabusResultRepository extends ChangeNotifier {
  late SyllabusResultBox _box;

  SyllabusResultRepository(SyllabusResultBox box) {
    _box = box;
  }

  Future<void> add(SyllabusResult syllabusResult) async {
    var box = await _box.box;
    await box.put(syllabusResult.hashCode, syllabusResult);
    notifyListeners();
  }

  Future<void> delete(SyllabusResult syllabusResult) async {
    var box = await _box.box;
    await box.delete(syllabusResult.hashCode);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _box.box;
    await box.deleteFromDisk();
    await _box.open();
    notifyListeners();
  }
}
