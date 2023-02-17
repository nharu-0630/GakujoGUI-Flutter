import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/home/widgets/contact.dart';
import 'package:gakujo_task/views/home/widgets/task.dart';
import 'package:gakujo_task/views/task/quiz.dart';
import 'package:gakujo_task/views/task/report.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

final scaffoldKey = GlobalKey<ScaffoldState>();

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => context.read<ApiProvider>().fetchAll(),
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
                    const Icon(Icons.task_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      'タスク',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
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
                  children: [
                    const Icon(Icons.message_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      'メッセージ',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
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
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            child: DrawerHeader(
              child: Column(
                children: [
                  FutureBuilder(
                    future: context.watch<SettingsRepository>().load(),
                    builder: ((context, AsyncSnapshot<Settings> snapshot) =>
                        snapshot.hasData
                            ? Text(
                                (snapshot.data?.lastLoginTime ==
                                        DateTime.fromMicrosecondsSinceEpoch(0)
                                    ? ''
                                    : DateFormat('yyyy/MM/dd HH:mm', 'ja')
                                        .format(snapshot.data!.lastLoginTime)),
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                            : const SizedBox.shrink()),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Row(
              children: const [
                Icon(Icons.text_snippet_rounded),
                SizedBox(width: 8.0),
                Text('レポート'),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportPage()));
            },
          ),
          ListTile(
            title: Row(
              children: const [
                Icon(Icons.quiz_rounded),
                SizedBox(width: 8.0),
                Text('小テスト'),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const QuizPage()));
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: FutureBuilder(
        future: context.watch<SettingsRepository>().load(),
        builder: (context, AsyncSnapshot<Settings> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: GestureDetector(
                onTap: () => scaffoldKey.currentState?.openDrawer(),
                child: snapshot.data?.profileImage == null
                    ? const Icon(Icons.person_rounded, size: 36.0)
                    : CircleAvatar(
                        backgroundImage: CachedMemoryImageProvider(
                            'ProfileImage',
                            base64: snapshot.data?.profileImage),
                      ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      centerTitle: false,
      title: FutureBuilder(
        future: context.watch<SettingsRepository>().load(),
        builder: (context, AsyncSnapshot<Settings> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    snapshot.data?.fullName == null
                        ? 'Hi!'
                        : 'Hi, ${snapshot.data?.fullName}!',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.sync_rounded),
                    onPressed: () async =>
                        context.read<ApiProvider>().fetchLogin(),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      bottom: buildAppBarBottom(context),
    );
  }
}
