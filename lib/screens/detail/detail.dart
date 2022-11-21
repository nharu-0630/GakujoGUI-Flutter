import 'package:flutter/material.dart';
import 'package:gakujo_task/models/task.dart';
import 'package:gakujo_task/screens/detail/widgets/date_picker.dart';
import 'package:gakujo_task/screens/detail/widgets/task_timeline.dart';

class DetailPage extends StatelessWidget {
  final Task task;
  DetailPage(this.task);

  @override
  Widget build(BuildContext context) {
    final detailList = task.desc;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DatePicker(),
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'タスク',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ]),
                    )
                  ],
                ),
              ),
            ),
          ),
          detailList == null
              ? SliverFillRemaining(
                  child: Container(
                      color: Colors.white,
                      child: const Center(
                          child: Text(
                        '今日のタスクはありません',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ))))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (_, index) => TaskTimeline(detailList[index]),
                      childCount: detailList.length))
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 90,
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios),
        iconSize: 20,
      ),
      // actions: const [
      //   Icon(
      //     Icons.more_vert,
      //     size: 40,
      //   )
      // ],
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${task.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 5),
            Text(
              '今日のタスクは${task.left}件あります',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            )
          ],
        ),
      ),
    );
  }
}
