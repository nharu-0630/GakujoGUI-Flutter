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
              'time': '9:00 am',
              'title': 'Go for a walk with dog',
              'slot': '9:00 - 10:00 am',
              'tlColor': kRedDark,
              'bgColor': kRedLight,
            },
            {
              'time': '10:00 am',
              'title': 'Shot on Dribble',
              'slot': '10:00 - 12:00 am',
              'tlColor': kBlueDark,
              'bgColor': kBlueLight,
            },
            // {
            //   'time': '11:00 am',
            //   'title': '',
            //   'slot': '',
            //   'tlColor': kBlueDark,
            // },
            // {
            //   'time': '12:00 am',
            //   'title': '',
            //   'slot': '',
            //   'tlColor': Colors.grey.withOpacity(0.3),
            // },
            {
              'time': '1:00 pm',
              'title': 'Call with client',
              'slot': '1:00 - 2:00 pm',
              'tlColor': kYellowDark,
              'bgColor': kYellowLight,
            },
            // {
            //   'time': '2:00 pm',
            //   'title': '',
            //   'slot': '',
            //   'tlColor': Colors.grey.withOpacity(0.3),
            // },
            // {
            //   'time': '3:00 pm',
            //   'title': '',
            //   'slot': '',
            //   'tlColor': Colors.grey.withOpacity(0.3),
            // },
          ]),
      Task(
        iconData: Icons.quiz_rounded,
        title: '小テスト',
        bgColor: kRedLight,
        iconColor: kRedDark,
        btnColor: kRed,
        left: 2,
        done: 8,
      ),
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
