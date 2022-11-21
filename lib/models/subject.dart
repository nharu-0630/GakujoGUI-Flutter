import 'package:flutter/material.dart';

class Subject {
  String className;
  Color bgColor;

  Subject(this.className, this.bgColor);

  static List<Subject> generateSubjects() {
    return [
      Subject('応用プログラミングA', const Color(0xFFFDBEC8)),
      Subject('ライティングスキルズⅠ', const Color(0xFFFED6C4)),
      Subject('計算理論', const Color(0xFFA8E4F2)),
      Subject('人工知能概論', const Color(0xFFFFE5A7)),
      Subject('応用プログラミングB', const Color(0xFFC3C1E6)),
      Subject('知的情報システム開発', const Color(0xFFFD95A2))
    ];
  }
}
