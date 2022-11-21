import 'package:flutter/material.dart';
import 'package:gakujo_task/models/task.dart';
import 'package:gakujo_task/screens/task/task.dart';

class Tasks extends StatelessWidget {
  final taskList = Task.generateTasks();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: taskList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemBuilder: ((context, index) =>
              _buildTask(context, taskList[index])),
        ));
  }

  Widget _buildTask(BuildContext context, Task task) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TaskPage(task)));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: task.bgColor, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
            task.iconData,
            color: task.iconColor,
            size: 35,
          ),
          const SizedBox(height: 25),
          Text(
            task.title!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTaskStatus(
                  task.btnColor!, task.iconColor!, '残り ${task.left}'),
              const SizedBox(width: 5),
              _buildTaskStatus(Colors.white, task.iconColor!, '完了 ${task.done}')
            ],
          )
        ]),
      ),
    );
  }

  Widget _buildTaskStatus(Color bgColor, Color txColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(color: txColor),
      ),
    );
  }
}
