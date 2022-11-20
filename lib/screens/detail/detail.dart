import 'package:flutter/material.dart';
import 'package:gakujo_task/models/task.dart';

class DetailPage extends StatelessWidget {
  final Task task;
  DetailPage(this.task);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Detail Page'),
      ),
    );
  }
}
