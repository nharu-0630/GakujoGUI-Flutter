import 'package:flutter/material.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/task.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/task/task.dart';
import 'package:provider/provider.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tasks = [
      Report.toTask(context.read<ApiProvider>().api.reports),
      Quiz.toTask(context.read<ApiProvider>().api.quizzes)
    ];
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemBuilder: ((context, index) =>
              _buildTaskTile(context, tasks[index])),
        ));
  }

  Widget _buildTaskTile(BuildContext context, Task task) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TaskPage(task)));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                task.iconData,
                color: task.iconColor,
                size: 36.0,
              ),
              Text(
                task.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _buildTaskStatus(
                  context,
                  task.iconColor!.withOpacity(0.4),
                  '残り ${task.left}',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskStatus(BuildContext context, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
