import 'package:flutter/material.dart';
import 'package:gakujo_task/models/task.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatelessWidget {
  final Task task;
  const TaskPage(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          task.desc == null || task.desc!.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.beach_access_rounded,
                            size: 48.0,
                          ),
                        ),
                        Text(
                          'タスクはありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (_, index) => _buildCard(
                              context,
                              task.desc![index]['title'],
                              task.desc![index]['slot'],
                              task.desc![index]['time'],
                            ),
                        childCount: task.desc!.length),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text('${task.title}'),
        centerTitle: false,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: (() {}),
            icon: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String slot, DateTime date) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slot,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  DateFormat('yyyy/MM/dd HH:mm', 'ja').format(date.toLocal()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
