import 'package:flutter/material.dart';
import 'package:gakujo_task/models/subject.dart';

class RecentSubjects extends StatelessWidget {
  final subjectList = Subject.generateSubjects();

  RecentSubjects({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: subjectList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemBuilder: ((context, index) => Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: subjectList[index].bgColor,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${subjectList[index].className.substring(0, 1)}\n${subjectList[index].className.substring(subjectList[index].className.length - 1)}',
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
