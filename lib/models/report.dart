import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_task/api/parse.dart';
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

  Report(
    this.subject,
    this.title,
    this.id,
    this.schoolYear,
    this.subjectCode,
    this.classCode,
    this.status,
    this.startDateTime,
    this.endDateTime,
    this.implementationFormat,
    this.operation,
    this.submittedDateTime,
    this.evaluationMethod,
    this.description,
    this.fileNames,
    this.message, {
    required this.isAcquired,
    required this.isArchived,
  });

  factory Report.fromElement(Element element) {
    var subject =
        element.querySelectorAll('td')[0].text.trimWhiteSpace().trimSubject();
    var title =
        element.querySelectorAll('td')[1].querySelector('a')!.text.trim();
    var id = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(1);
    var schoolYear = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(3);
    var subjectCode = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(4);
    var classCode = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(5);
    var status = element.querySelectorAll('td')[2].text.trim();
    var startDateTime =
        element.querySelectorAll('td')[3].text.trimSpanDateTime(0);
    var endDateTime =
        element.querySelectorAll('td')[3].text.trimSpanDateTime(1);
    var implementationFormat = element.querySelectorAll('td')[5].text.trim();
    var operation = element.querySelectorAll('td')[6].text.trim();
    var submittedDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
    if (element.querySelectorAll('td')[4].text != '') {
      submittedDateTime =
          element.querySelectorAll('td')[4].text.trim().trimDateTime();
    }
    return Report(
      subject,
      title,
      id,
      schoolYear,
      subjectCode,
      classCode,
      status,
      startDateTime,
      endDateTime,
      implementationFormat,
      operation,
      submittedDateTime,
      '',
      '',
      null,
      '',
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
  String toString() => '[$status] $subject $title -> $endDateTime';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
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
    if (compare1 != 0) {
      return compare1;
    }
    var compare2 = startDateTime.compareTo(other.startDateTime);
    if (compare2 != 0) {
      return compare2;
    }
    var compare3 = subjectCode.compareTo(other.subjectCode);
    if (compare3 != 0) {
      return compare3;
    }
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
  late ReportBox _reportBox;

  ReportRepository(ReportBox reportBox) {
    _reportBox = reportBox;
  }

  Future<void> add(Report report, {bool overwrite = false}) async {
    var box = await _reportBox.box;
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
    var box = await _reportBox.box;
    await box.delete(report.id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _reportBox.box;
    await box.deleteFromDisk();
    await _reportBox.open();
    notifyListeners();
  }

  Future<Report?> get(String id) async {
    var box = await _reportBox.box;
    return box.get(id);
  }

  Future<List<Report>> getAll() async {
    var box = await _reportBox.box;
    return box.values.toList().cast<Report>();
  }

  Future<void> setArchive(String id, bool value) async {
    var box = await _reportBox.box;
    box.get(id).isArchived = value;
    notifyListeners();
  }
}
