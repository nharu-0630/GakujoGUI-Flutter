import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_gui/api/parse.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'questionnaire.g.dart';

@HiveType(typeId: 12)
class Questionnaire implements Comparable<Questionnaire> {
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
  DateTime endDateTime;
  @HiveField(9)
  String operation;
  @HiveField(10)
  int questionsCount;
  @HiveField(11)
  String submitterName;
  @HiveField(12)
  String description;
  @HiveField(13)
  List<String>? fileNames;
  @HiveField(14)
  String message;
  @HiveField(15)
  bool isAcquired = false;
  @HiveField(16)
  bool isArchived = false;

  Questionnaire({
    required this.subject,
    required this.title,
    required this.id,
    required this.schoolYear,
    required this.subjectCode,
    required this.classCode,
    required this.status,
    required this.startDateTime,
    required this.endDateTime,
    required this.operation,
    required this.questionsCount,
    required this.submitterName,
    required this.description,
    required this.fileNames,
    required this.message,
    required this.isAcquired,
    required this.isArchived,
  });

  factory Questionnaire.fromElement(Element element) {
    return Questionnaire(
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
      operation: element.querySelectorAll('td')[4].text.trim(),
      questionsCount: -1,
      submitterName: '',
      description: '',
      fileNames: null,
      message: '',
      isAcquired: false,
      isArchived: false,
    );
  }

  bool get isSubmitted => operation == '提出済';

  void toRefresh(Questionnaire questionnaire) {
    title = questionnaire.title;
    status = questionnaire.status;
    startDateTime = questionnaire.startDateTime;
    endDateTime = questionnaire.endDateTime;
    operation = questionnaire.operation;
  }

  void toDetail(Document document) {
    isAcquired = true;
    questionsCount = int.tryParse(document
            .querySelectorAll('table.ttb_entry > tbody > tr > td')[2]
            .text
            .replaceFirst('問', '')
            .trim()) ??
        -1;
    submitterName =
        document.querySelectorAll('table.ttb_entry > tbody > tr > td')[3].text;
    description =
        document.querySelectorAll('table.ttb_entry > tbody > tr > td')[4].text;
    message =
        document.querySelectorAll('table.ttb_entry > tbody > tr > td')[6].text;
  }

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      title.toLowerCase().contains(value.toLowerCase()) ||
      description.toLowerCase().contains(value.toLowerCase()) ||
      message.toLowerCase().contains(value.toLowerCase());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Questionnaire) {
      return subjectCode == other.subjectCode &&
          classCode == other.classCode &&
          id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => subjectCode.hashCode ^ classCode.hashCode ^ id.hashCode;

  @override
  int compareTo(Questionnaire other) {
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

class QuestionnaireBox {
  Future<Box> box = Hive.openBox<Questionnaire>('questionnaire');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Questionnaire>('questionnaire');
    }
  }
}

class QuestionnaireRepository extends ChangeNotifier {
  late QuestionnaireBox _box;

  QuestionnaireRepository(QuestionnaireBox box) {
    _box = box;
  }

  Future<void> add(Questionnaire questionnaire,
      {bool overwrite = false}) async {
    var box = await _box.box;
    if (!overwrite && box.containsKey(questionnaire.id)) return;
    await box.put(questionnaire.id, questionnaire);
    notifyListeners();
  }

  Future<void> addAll(List<Questionnaire> questionnaires,
      {bool overwrite = false}) async {
    for (var questionnaire in questionnaires) {
      await add(questionnaire, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(Questionnaire questionnaire) async {
    var box = await _box.box;
    await box.delete(questionnaire.id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _box.box;
    await box.deleteFromDisk();
    await _box.open();
    notifyListeners();
  }

  Future<Questionnaire?> get(int key) async {
    var box = await _box.box;
    return box.get(key);
  }

  Future<List<Questionnaire>> getAll() async {
    var box = await _box.box;
    return box.values.toList().cast<Questionnaire>();
  }

  Future<List<Questionnaire>> getSubmittable() async {
    var box = await _box.box;
    return box.values
        .toList()
        .cast<Questionnaire>()
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
