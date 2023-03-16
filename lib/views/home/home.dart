import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/KIcons.dart';
import 'package:gakujo_gui/views/home/widgets/contact.dart';
import 'package:gakujo_gui/views/home/widgets/task.dart';
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => context.read<ApiRepository>().fetchAll(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StickyHeader(
              header: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(KIcons.task),
                    const SizedBox(width: 8.0),
                    Text(
                      'タスク',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              content: const TaskWidget(),
            ),
            const SizedBox(height: 24.0),
            StickyHeader(
              header: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(KIcons.contact),
                    const SizedBox(width: 8.0),
                    Text(
                      'メッセージ',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              content: const ContactWidget(),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
