import 'package:flutter/material.dart';

class Subject {
  num id;
  String className;
  Color bgColor;

  Subject(this.id, this.className, this.bgColor);

  String shortClassName() {
    return className.substring(0, 1) +
        className.substring(className.length - 1);
  }

  static List<Subject> generateSubjects() {
    return [
      Subject(1, '応用プログラミングA', const Color(0xFFFDBEC8)),
      Subject(2, 'ライティングスキルズⅠ', const Color(0xFFFED6C4)),
      Subject(3, '計算理論', const Color(0xFFA8E4F2)),
      Subject(4, '人工知能概論', const Color(0xFFFFE5A7)),
      Subject(5, '応用プログラミングB', const Color(0xFFC3C1E6)),
      Subject(6, '知的情報システム開発', const Color(0xFFFD95A2))
    ];
  }
}
