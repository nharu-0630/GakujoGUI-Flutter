import 'dart:convert';
import 'dart:ui';

import 'package:crypto/crypto.dart' show md5;
import 'package:html/dom.dart';

class Subject {
  String subjectsName;
  String teacherName;
  String classRoom;
  Color subjectColor;

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
      Color(int.parse('0xFF${bytes.toString().substring(0, 6)}')),
    );
  }

  static Map<String, dynamic> toMap(Subject subject) => <String, dynamic>{
        'subjectsName': subject.subjectsName,
        'teacherName': subject.teacherName,
        'classRoom': subject.classRoom,
        'subjectColor': subject.subjectColor.value,
      };

  factory Subject.fromJson(dynamic json) => Subject(
        json['subjectsName'] as String,
        json['teacherName'] as String,
        json['classRoom'] as String,
        Color(json['subjectColor']),
      );

  static String encode(List<Subject> subjects) => json.encode(
        subjects.map<Map<String, dynamic>>(Subject.toMap).toList(),
      );

  static List<Subject> decode(String subjects) => json.decode(subjects) is List
      ? (json.decode(subjects) as List).map<Subject>(Subject.fromJson).toList()
      : [];
}
