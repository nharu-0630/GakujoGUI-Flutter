import 'package:flutter/material.dart';

class Subject {
  String className;
  Color bgColor;

  Subject(this.className, this.bgColor);

  static List<Subject> generateSubjects() {
    return [
      Subject('応用プログラミングA', const Color(0xFFFDBEC8)),
      Subject('人工知能概論', const Color(0xFFFED6C4)),
      Subject('計算機アーキテクチャⅠ', const Color(0xFFA8E4F2)),
      Subject('情報と法', const Color(0xFFC3C1E6)),
      Subject('物理の世界', const Color(0xFFFD95A2)),
      Subject('データベースシステム論', const Color(0xFFFDBEC8)),
      Subject('応用プログラミングB', const Color(0xFFFED6C4)),
      Subject('符号理論', const Color(0xFFA8E4F2)),
      Subject('科学と技術', const Color(0xFFC3C1E6)),
      Subject('ライティングスキルズⅠ', const Color(0xFFFD95A2)),
      Subject('コンパイラ', const Color(0xFFFDBEC8)),
      Subject('計算理論', const Color(0xFFFED6C4)),
      Subject('知的情報システム開発Ⅰ', const Color(0xFFA8E4F2)),
      Subject('社会モデル', const Color(0xFFC3C1E6)),
    ];
  }
}
