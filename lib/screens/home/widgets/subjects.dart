import 'package:flutter/material.dart';
import 'package:gakujo_task/models/subject.dart';

class RecentSubjects extends StatelessWidget {
  final subjects = Subject.generateSubjects();

  RecentSubjects({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: subjects.length,
          itemBuilder: ((context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 60,
                decoration: BoxDecoration(
                  color: subjects[index].bgColor,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${subjects[index].className.substring(0, 1)}\n${subjects[index].className.substring(subjects[index].className.length - 1)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ))),
    );
  }
}
