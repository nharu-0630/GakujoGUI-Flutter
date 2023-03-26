import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'subject.g.dart';

@HiveType(typeId: 2)
class Subject implements Comparable<Subject> {
  @HiveField(0)
  String subject;
  @HiveField(1)
  String teacher;
  @HiveField(2)
  String className;

  Subject({
    required this.subject,
    required this.teacher,
    required this.className,
  });

  factory Subject.fromElement(Element element) {
    return Subject(
      subject: element
          .querySelectorAll('li')[0]
          .text
          .trim()
          .replaceAll(RegExp(r'（.*）(.*)'), ''),
      teacher: element.querySelectorAll('li')[1].text.trim(),
      className: element.querySelectorAll('li')[2].text.trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Subject) {
      return subject == other.subject &&
          teacher == other.teacher &&
          className == other.className;
    }
    return false;
  }

  @override
  int get hashCode => subject.hashCode ^ teacher.hashCode ^ className.hashCode;

  @override
  int compareTo(Subject other) {
    var compare1 = subject.compareTo(other.subject);
    if (compare1 != 0) return compare1;
    var compare2 = teacher.compareTo(other.teacher);
    if (compare2 != 0) return compare2;
    var compare3 = className.compareTo(other.className);
    return compare3;
  }
}

class SubjectBox {
  Future<Box> box = Hive.openBox<Subject>('subject');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Subject>('subject');
    }
  }
}

class SubjectRepository extends ChangeNotifier {
  late SubjectBox _box;

  SubjectRepository(SubjectBox box) {
    _box = box;
  }

  Future<void> add(Subject subject, {bool overwrite = false}) async {
    var box = await _box.box;
    if (!overwrite && box.containsKey(subject.hashCode)) return;
    await box.put(subject.hashCode, subject);
    notifyListeners();
  }

  Future<void> addAll(List<Subject> subjects, {bool overwrite = false}) async {
    for (var subject in subjects) {
      await add(subject, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(Subject subjects) async {
    var box = await _box.box;
    await box.delete(subjects.hashCode);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _box.box;
    await box.deleteFromDisk();
    await _box.open();
    notifyListeners();
  }

  Future<List<Subject>> getAll() async {
    var box = await _box.box;
    return box.values.toList().cast<Subject>();
  }
}
