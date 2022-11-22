import 'package:flutter/material.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';

class Task {
  IconData? iconData;
  String? title;
  Color? bgColor;
  Color? iconColor;
  Color? btnColor;
  num? left;
  num? done;
  List<Map<String, dynamic>>? desc;
  bool isLast;

  Task(
      {this.iconData,
      this.title,
      this.bgColor,
      this.iconColor,
      this.btnColor,
      this.left,
      this.done,
      this.desc,
      this.isLast = false});

  static List<Task> generateTasks() {
    return [
      Report.toTask([
        Report('科目A', 'レポート1', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目B', 'レポート2', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目C', 'レポート3', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目A', 'レポート1', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目B', 'レポート2', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目C', 'レポート3', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目A', 'レポート1', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目B', 'レポート2', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目C', 'レポート3', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目A', 'レポート1', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目B', 'レポート2', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false),
        Report('科目C', 'レポート3', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', DateTime.now(), '', '', '',
            isAcquired: false, isArchived: false)
      ]),
      Quiz.toTask([
        Quiz('科目A', '小テスト1', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', '', 0, '', '', '',
            isAcquired: false, isArchived: false),
        Quiz('科目B', '小テスト2', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', '', 0, '', '', '',
            isAcquired: false, isArchived: false),
        Quiz('科目C', '小テスト3', '0', '2022', '0', '0', '', DateTime.now(),
            DateTime.now(), '', '', '', 0, '', '', '',
            isAcquired: false, isArchived: false),
      ])
    ];
  }
}
