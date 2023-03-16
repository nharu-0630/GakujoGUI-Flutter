import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_gui/api/parse.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'quiz.g.dart';

@HiveType(typeId: 5)
class Quiz implements Comparable<Quiz> {
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
  DateTime startDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  @HiveField(8)
  DateTime endDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  @HiveField(9)
  String submissionStatus;
  @HiveField(10)
  String implementationFormat;
  @HiveField(11)
  String operation;
  @HiveField(12)
  int questionsCount;
  @HiveField(13)
  String evaluationMethod;
  @HiveField(14)
  String description;
  @HiveField(15)
  List<String>? fileNames;
  @HiveField(16)
  String message;
  @HiveField(17)
  bool isAcquired = false;
  @HiveField(18)
  bool isArchived = false;

  Quiz({
    required this.subject,
    required this.title,
    required this.id,
    required this.schoolYear,
    required this.subjectCode,
    required this.classCode,
    required this.status,
    required this.startDateTime,
    required this.endDateTime,
    required this.submissionStatus,
    required this.implementationFormat,
    required this.operation,
    required this.questionsCount,
    required this.evaluationMethod,
    required this.description,
    required this.fileNames,
    required this.message,
    required this.isAcquired,
    required this.isArchived,
  });

  factory Quiz.fromElement(Element element) {
    return Quiz(
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
      submissionStatus: element.querySelectorAll('td')[4].text.trim(),
      implementationFormat: element.querySelectorAll('td')[5].text.trim(),
      operation: element.querySelectorAll('td')[6].text.trim(),
      questionsCount: -1,
      evaluationMethod: '',
      description: '',
      fileNames: null,
      message: '',
      isAcquired: false,
      isArchived: false,
    );
  }

  bool get isSubmitted => submissionStatus != '未提出';

  void toRefresh(Quiz quiz) {
    title = quiz.title;
    status = quiz.status;
    startDateTime = quiz.startDateTime;
    endDateTime = quiz.endDateTime;
    submissionStatus = quiz.submissionStatus;
    implementationFormat = quiz.implementationFormat;
    operation = quiz.operation;
  }

  void toDetail(Document document) {
    isAcquired = true;
    questionsCount = int.tryParse(
          document
                  .querySelector('#area > table > tbody > tr:nth-child(2) > td')
                  ?.text
                  .replaceFirst('問', '')
                  .trim() ??
              '',
        ) ??
        -1;
    evaluationMethod = document
            .querySelector('#area > table > tbody > tr:nth-child(3) > td')
            ?.text ??
        '';
    description = document
            .querySelector('#area > table > tbody > tr:nth-child(4) > td')
            ?.text ??
        '';
    message = document
            .querySelector('#area > table > tbody > tr:nth-child(6) > td')
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
    if (identical(this, other)) {
      return true;
    }
    if (other is Quiz) {
      return subjectCode == other.subjectCode &&
          classCode == other.classCode &&
          id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => subjectCode.hashCode ^ classCode.hashCode ^ id.hashCode;

  @override
  int compareTo(Quiz other) {
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

class QuizBox {
  Future<Box> box = Hive.openBox<Quiz>('quiz');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Quiz>('quiz');
    }
  }
}

class QuizRepository extends ChangeNotifier {
  late QuizBox _quizBox;

  QuizRepository(QuizBox quizBox) {
    _quizBox = quizBox;
  }

  Future<void> add(Quiz quiz, {bool overwrite = false}) async {
    var box = await _quizBox.box;
    if (!overwrite && box.containsKey(quiz.id)) {
      Quiz oldQuiz = box.get(quiz.id)!;
      oldQuiz.toRefresh(quiz);
      await box.put(quiz.id, oldQuiz);
    }
    await box.put(quiz.id, quiz);
    notifyListeners();
  }

  Future<void> addAll(List<Quiz> quizzes, {bool overwrite = false}) async {
    for (var quiz in quizzes) {
      await add(quiz, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(Quiz quiz) async {
    var box = await _quizBox.box;
    await box.delete(quiz.id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _quizBox.box;
    await box.deleteFromDisk();
    await _quizBox.open();
    notifyListeners();
  }

  Future<Quiz?> get(String id) async {
    var box = await _quizBox.box;
    return box.get(id);
  }

  Future<List<Quiz>> getAll() async {
    var box = await _quizBox.box;
    return box.values.toList().cast<Quiz>();
  }

  Future<void> setArchive(String id, bool value) async {
    var box = await _quizBox.box;
    box.get(id).isArchived = value;
    notifyListeners();
  }
}
