import 'package:flutter/material.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/views/home/widgets/contact.dart';
import 'package:gakujo_gui/views/home/widgets/task.dart';
import 'package:multi_split_view/multi_split_view.dart';
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
        body: OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildVertical(context)
                    : _buildHorizontal(context)));
  }

  Widget _buildHeader(IconData icon, String title) {
    return Builder(builder: (context) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
          ],
        ),
      );
    });
  }

  Widget _buildVertical(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        StickyHeader(
          header: _buildHeader(KIcons.task, 'タスク'),
          content: const TaskWidget(),
        ),
        const SizedBox(height: 24.0),
        StickyHeader(
          header: _buildHeader(KIcons.contact, 'メッセージ'),
          content: const ContactWidget(),
        ),
      ],
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return MultiSplitView(
      resizable: false,
      children: [
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StickyHeader(
              header: _buildHeader(KIcons.task, 'タスク'),
              content: const TaskWidget(),
            ),
          ],
        ),
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            StickyHeader(
              header: _buildHeader(KIcons.contact, 'メッセージ'),
              content: const ContactWidget(),
            ),
          ],
        ),
      ],
    );
  }
}
