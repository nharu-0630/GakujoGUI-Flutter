import 'package:flutter/material.dart';
import 'package:gakujo_task/constants/colors.dart';

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
      Task(
          iconData: Icons.text_snippet_rounded,
          title: 'レポート',
          bgColor: kYellowLight,
          iconColor: kYellowDark,
          btnColor: kYellow,
          left: 3,
          done: 1,
          desc: [
            {
              'time': '9:00',
              'title': '第7回 レポート課題',
              'slot': '応用プログラミングB',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
            {
              'time': '10:00',
              'title': 'オプション課題4',
              'slot': '応用プログラミングB',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
            {
              'time': '13:00',
              'title': '第7回（11/16）お題',
              'slot': 'コンパイラ',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
          ]),
      Task(
          iconData: Icons.quiz_rounded,
          title: '小テスト',
          bgColor: kRedLight,
          iconColor: kRedDark,
          btnColor: kRed,
          left: 2,
          done: 8,
          desc: [
            {
              'time': '9:00',
              'title': '第7回 レポート課題',
              'slot': '応用プログラミングB',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
            {
              'time': '10:00',
              'title': 'オプション課題4',
              'slot': '応用プログラミングB',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
            {
              'time': '13:00',
              'title': '第7回（11/16）お題',
              'slot': 'コンパイラ',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
          ]),
      // Task(
      //   iconData: Icons.favorite_rounded,
      //   title: 'Health',
      //   bgColor: kBlueLight,
      //   iconColor: kBlueDark,
      //   btnColor: kBlue,
      //   left: 1,
      //   done: 1,
      // ),
      // Task(isLast: true)
    ];
  }
}
