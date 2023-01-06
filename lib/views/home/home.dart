import 'package:flutter/material.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/home/widgets/contact.dart';
import 'package:gakujo_task/views/home/widgets/status.dart';
import 'package:gakujo_task/views/home/widgets/task.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ApiProvider>().fetchAll(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const StatusWidget(),
          StickyHeader(
            header: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'タスク',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync_rounded),
                    onPressed: () async =>
                        context.read<ApiProvider>().fetchTasks(),
                  ),
                ],
              ),
            ),
            content: const TaskWidget(),
          ),
          const SizedBox(height: 16.0),
          StickyHeader(
            header: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'メッセージ',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync_rounded),
                    onPressed: () async =>
                        context.read<ApiProvider>().fetchContacts(),
                  ),
                ],
              ),
            ),
            content: const ContactWidget(),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
