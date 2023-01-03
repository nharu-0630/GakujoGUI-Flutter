import 'package:flutter/material.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/home/widgets/contact.dart';
import 'package:gakujo_task/views/home/widgets/status.dart';
import 'package:gakujo_task/views/home/widgets/task.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApiProvider>().fetchLogin();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const StatusWidget(),
          StickyHeader(
            header: Container(
              width: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'タスク',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            content: const TaskWidget(),
          ),
          StickyHeader(
            header: Container(
              width: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'メッセージ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            content: ContactWidget(),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
