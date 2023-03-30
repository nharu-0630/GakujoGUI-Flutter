import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_gui/api/parse.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'report.g.dart';

@HiveType(typeId: 4)
class Report implements Comparable<Report> {
  @HiveField(0)
  String subject;
  @HiveField(1)
  String title;
  @HiveField(2)
  String id;
  @HiveField(3)
  String schoolYear;
  @HiveField(4)
  String subjectCode;
  @HiveField(5)
  String classCode;
  @HiveField(6)
  String status;
  @HiveField(7)
  DateTime startDateTime;
  @HiveField(8)
  DateTime endDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  @HiveField(9)
  String implementationFormat;
  @HiveField(10)
  String operation;
  @HiveField(11)
  DateTime submittedDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  @HiveField(12)
  String evaluationMethod;
  @HiveField(13)
  String description;
  @HiveField(14)
  List<String>? fileNames;
  @HiveField(15)
  String message;
  @HiveField(16)
  bool isAcquired = false;
  @HiveField(17)
  bool isArchived = false;

  Report({
    required this.subject,
    required this.title,
    required this.id,
    required this.schoolYear,
    required this.subjectCode,
    required this.classCode,
    required this.status,
    required this.startDateTime,
    required this.endDateTime,
    required this.implementationFormat,
    required this.operation,
    required this.submittedDateTime,
    required this.evaluationMethod,
    required this.description,
    required this.fileNames,
    required this.message,
    required this.isAcquired,
    required this.isArchived,
  });

  factory Report.fromElement(Element element) {
    return Report(
      subject:
          element.querySelectorAll('td')[0].text.trimWhiteSpace().trimSubject(),
      title: element.querySelectorAll('td')[1].querySelector('a')!.text.trim(),
      id: element
          .querySelectorAll('td')[1]
          .querySelector('a')!
          .attributes['onclick']!
          .trimJsArgs(1),
      schoolYear: element
          .querySelectorAll('td')[1]
          .querySelector('a')!
          .attributes['onclick']!
          .trimJsArgs(3),
      subjectCode: element
          .querySelectorAll('td')[1]
          .querySelector('a')!
          .attributes['onclick']!
          .trimJsArgs(4),
      classCode: element
          .querySelectorAll('td')[1]
          .querySelector('a')!
          .attributes['onclick']!
          .trimJsArgs(5),
      status: element.querySelectorAll('td')[2].text.trim(),
      startDateTime: element.querySelectorAll('td')[3].text.toSpanDateTime(0),
      endDateTime: element.querySelectorAll('td')[3].text.toSpanDateTime(1),
      implementationFormat: element.querySelectorAll('td')[5].text.trim(),
      operation: element.querySelectorAll('td')[6].text.trim(),
      submittedDateTime: element.querySelectorAll('td')[4].text.isNotEmpty
          ? element.querySelectorAll('td')[4].text.trim().toDateTime()
          : DateTime.fromMicrosecondsSinceEpoch(0),
      evaluationMethod: '',
      description: '',
      fileNames: null,
      message: '',
      isAcquired: false,
      isArchived: false,
    );
  }

  bool get isSubmitted =>
      submittedDateTime != DateTime.fromMicrosecondsSinceEpoch(0);

  void toRefresh(Report report) {
    title = report.title;
    status = report.status;
    startDateTime = report.startDateTime;
    endDateTime = report.endDateTime;
    submittedDateTime = report.submittedDateTime;
    implementationFormat = report.implementationFormat;
    operation = report.operation;
  }

  void toDetail(Document document) {
    isAcquired = true;
    evaluationMethod = document
            .querySelector('#area > table > tbody > tr:nth-child(2) > td')
            ?.text ??
        '';
    description = document
            .querySelector('#area > table > tbody > tr:nth-child(3) > td')
            ?.text ??
        '';
    message = document
            .querySelector('#area > table > tbody > tr:nth-child(5) > td')
            ?.text ??
        '';
  }

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      title.toLowerCase().contains(value.toLowerCase()) ||
      description.toLowerCase().contains(value.toLowerCase()) ||
      message.toLowerCase().contains(value.toLowerCase());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Report) {
      return subjectCode == other.subjectCode &&
          classCode == other.classCode &&
          id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => subjectCode.hashCode ^ classCode.hashCode ^ id.hashCode;

  @override
  int compareTo(Report other) {
    var compare1 = endDateTime.compareTo(other.endDateTime);
    if (compare1 != 0) return compare1;
    var compare2 = startDateTime.compareTo(other.startDateTime);
    if (compare2 != 0) return compare2;
    var compare3 = subjectCode.compareTo(other.subjectCode);
    if (compare3 != 0) return compare3;
    var compare4 = id.compareTo(other.id);
    return compare4;
  }
}

class ReportBox {
  Future<Box> box = Hive.openBox<Report>('report');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Report>('report');
    }
  }
}

class ReportRepository extends ChangeNotifier {
  late ReportBox _box;

  ReportRepository(ReportBox box) {
    _box = box;
  }

  Future<void> add(Report report, {bool overwrite = false}) async {
    var box = await _box.box;
    if (!overwrite && box.containsKey(report.id)) {
      Report oldReport = box.get(report.id)!;
      oldReport.toRefresh(report);
      await box.put(report.id, oldReport);
    }
    await box.put(report.id, report);
    notifyListeners();
  }

  Future<void> addAll(List<Report> reports, {bool overwrite = false}) async {
    for (var report in reports) {
      await add(report, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(Report report) async {
    var box = await _box.box;
    await box.delete(report.id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _box.box;
    await box.deleteFromDisk();
    await _box.open();
    notifyListeners();
  }

  Future<Report?> get(String id) async {
    var box = await _box.box;
    return box.get(id);
  }

  Future<List<Report>> getAll() async {
    var box = await _box.box;
    return box.values.toList().cast<Report>();
  }

  Future<List<Report>> getSubmittable() async {
    var box = await _box.box;
    return box.values
        .toList()
        .cast<Report>()
        .where((e) => !(e.isArchived ||
            !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now()))))
        .toList();
  }

  Future<void> setArchive(String id, bool value) async {
    var box = await _box.box;
    box.get(id).isArchived = value;
    notifyListeners();
  }
}
