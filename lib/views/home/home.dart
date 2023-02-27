import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/views/home/widgets/contact.dart';
import 'package:gakujo_task/views/home/widgets/task.dart';
import 'package:gakujo_task/views/page/class_link.dart';
import 'package:gakujo_task/views/page/grade.dart';
import 'package:gakujo_task/views/page/quiz.dart';
import 'package:gakujo_task/views/page/report.dart';
import 'package:gakujo_task/views/page/shared_file.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

var scaffoldKey = GlobalKey<ScaffoldState>();

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            child: DrawerHeader(
              child: Column(
                children: [
                  Text(
                    'GakujoTask',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  FutureBuilder(
                    future: context.watch<SettingsRepository>().load(),
                    builder: ((context, AsyncSnapshot<Settings> snapshot) =>
                        snapshot.hasData
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_clock_rounded),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        DateFormat('yyyy/MM/dd HH:mm', 'ja')
                                            .format(
                                                snapshot.data!.lastLoginTime),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_rounded),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        snapshot.data!.username ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.security_rounded),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        snapshot.data!.accessEnvironmentName ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox.shrink()),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Icon(Icons.text_snippet_rounded),
                const SizedBox(width: 8.0),
                Text(
                  'レポート',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Expanded(child: SizedBox()),
                FutureBuilder(
                  future: context.watch<ReportRepository>().getAll(),
                  builder: (context, AsyncSnapshot<List<Report>> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!
                            .where((e) => !(e.isArchived ||
                                !(!e.isSubmitted &&
                                    e.endDateTime.isAfter(DateTime.now()))))
                            .length
                            .toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
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
              children: [
                const Icon(Icons.quiz_rounded),
                const SizedBox(width: 8.0),
                Text(
                  '小テスト',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Expanded(child: SizedBox()),
                FutureBuilder(
                  future: context.watch<QuizRepository>().getAll(),
                  builder: (context, AsyncSnapshot<List<Quiz>> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!
                            .where((e) => !(e.isArchived ||
                                !(!e.isSubmitted &&
                                    e.endDateTime.isAfter(DateTime.now()))))
                            .length
                            .toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const QuizPage()));
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Icon(Icons.folder_shared_rounded),
                const SizedBox(width: 8.0),
                Text(
                  '授業共有ファイル',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SharedFilePage()));
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Icon(Icons.link_rounded),
                const SizedBox(width: 8.0),
                Text(
                  '授業リンク',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ClassLinkPage()));
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Icon(Icons.school_rounded),
                const SizedBox(width: 8.0),
                Text(
                  '成績情報',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GradePage()));
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
            return Row(
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
                      context.read<ApiRepository>().fetchAll(),
                ),
              ],
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
