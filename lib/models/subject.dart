import 'dart:convert';

import 'package:crypto/crypto.dart' show md5;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'subject.g.dart';

@HiveType(typeId: 2)
class Subject implements Comparable<Subject> {
  @HiveField(0)
  String subjectsName;
  @HiveField(1)
  String teacherName;
  @HiveField(2)
  String classRoom;
  @HiveField(3)
  int? subjectColor;

  Subject(
    this.subjectsName,
    this.teacherName,
    this.classRoom,
    this.subjectColor,
  );

  factory Subject.fromElement(Element element) {
    var bytes =
        md5.convert(utf8.encode(element.querySelectorAll('li')[0].text.trim()));
    return Subject(
      element
          .querySelectorAll('li')[0]
          .text
          .trim()
          .replaceAll(RegExp(r'（.*）(.*)'), ''),
      element.querySelectorAll('li')[1].text.trim(),
      element.querySelectorAll('li')[2].text.trim(),
      int.parse('0xFF${bytes.toString().substring(0, 6)}'),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Subject) {
      return subjectsName == other.subjectsName &&
          teacherName == other.teacherName &&
          classRoom == other.classRoom;
    }
    return false;
  }

  @override
  int get hashCode =>
      subjectsName.hashCode ^ teacherName.hashCode ^ classRoom.hashCode;

  @override
  int compareTo(Subject other) {
    var compare1 = subjectsName.compareTo(other.subjectsName);
    if (compare1 != 0) {
      return compare1;
    }
    var compare2 = teacherName.compareTo(other.teacherName);
    if (compare2 != 0) {
      return compare2;
    }
    var compare3 = classRoom.compareTo(other.classRoom);
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
  late SubjectBox _subjectBox;

  SubjectRepository(SubjectBox subjectBox) {
    _subjectBox = subjectBox;
  }

  Future<void> add(Subject subject, {bool overwrite = false}) async {
    var box = await _subjectBox.box;
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
    var box = await _subjectBox.box;
    await box.delete(subjects.hashCode);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _subjectBox.box;
    await box.deleteFromDisk();
    await _subjectBox.open();
    notifyListeners();
  }

  Future<List<Subject>> getAll() async {
    var box = await _subjectBox.box;
    return box.values.toList().cast<Subject>();
  }
}
