import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/settings.dart';
import 'package:gakujo_gui/views/page/class_link.dart';
import 'package:gakujo_gui/views/page/grade.dart';
import 'package:gakujo_gui/views/page/quiz.dart';
import 'package:gakujo_gui/views/page/report.dart';
import 'package:gakujo_gui/views/page/shared_file.dart';
import 'package:gakujo_gui/views/settings/settings.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

ListView buildFileList(List<String>? fileNames,
    {Axis scrollDirection = Axis.vertical}) {
  return ListView.builder(
    scrollDirection: scrollDirection,
    padding: const EdgeInsets.all(0.0),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: fileNames?.length ?? 0,
    itemBuilder: (context, index) {
      return ListTile(
        title: Row(
          children: [
            _buildExtIcon(p.extension(fileNames![index]).replaceFirst('.', '')),
            const SizedBox(width: 8.0),
            Text(p.basename(fileNames[index])),
          ],
        ),
        onTap: () async => _openFile(fileNames[index]),
      );
    },
  );
}

void _openFile(String filename) async {
  var path = p.join((await getApplicationDocumentsDirectory()).path, filename);
  if (File(path).existsSync()) {
    OpenFile.open(path);
  } else {
    Fluttertoast.showToast(
      msg: 'Not exist file.',
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 5,
    );
  }
}

Icon _buildExtIcon(String ext) {
  switch (ext) {
    case 'pdf':
      return const Icon(LineIcons.pdfFile);
    case 'doc':
    case 'docx':
      return const Icon(LineIcons.wordFile);
    case 'xls':
    case 'xlsx':
      return const Icon(LineIcons.excelFile);
    case 'ppt':
    case 'pptx':
      return const Icon(LineIcons.powerpointFile);
    case 'zip':
    case 'rar':
      return const Icon(LineIcons.archiveFile);
    case 'csv':
      return const Icon(LineIcons.fileCsv);
    case 'txt':
      return const Icon(LineIcons.alternateFile);
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return const Icon(LineIcons.imageFile);
    case 'mp4':
    case 'mov':
      return const Icon(LineIcons.videoFile);
    case 'mp3':
    case 'wav':
      return const Icon(LineIcons.audioFile);
    default:
      return const Icon(LineIcons.file);
  }
}

Widget buildAutoLinkText(BuildContext context, String text) {
  return SelectableAutoLinkText(
    text,
    style: Theme.of(context).textTheme.bodyMedium,
    linkStyle: const TextStyle(color: Colors.blueAccent),
    onTap: (url) => launchUrlString(url, mode: LaunchMode.inAppWebView),
    onLongPress: (url) => Share.share(url),
    linkRegExpPattern:
        r'https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
  );
}

Widget buildDrawer(BuildContext context) {
  return FutureBuilder(
      future: Future.wait([
        context.watch<SettingsRepository>().load(),
        context.watch<ReportRepository>().getAll(),
        context.watch<QuizRepository>().getAll()
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        return Drawer(
          child: ListView(
            children: [
              SizedBox(
                child: DrawerHeader(
                  child: Column(
                    children: [
                      Text(
                        'GakujoGUI',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16.0),
                      snapshot.hasData
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(LineIcons.userClock),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      (snapshot.data![0] as Settings)
                                          .lastLoginTime
                                          .toLocal()
                                          .toDetailString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(LineIcons.identificationBadge),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      (snapshot.data![0] as Settings)
                                              .username ??
                                          '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(LineIcons.userShield),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      (snapshot.data![0] as Settings)
                                              .accessEnvironmentName ??
                                          '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(KIcons.report),
                    const SizedBox(width: 8.0),
                    Text(
                      'レポート',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Expanded(child: SizedBox()),
                    snapshot.hasData
                        ? Text(
                            (snapshot.data![1] as List<Report>)
                                .where((e) => !(e.isArchived ||
                                    !(!e.isSubmitted &&
                                        e.endDateTime.isAfter(DateTime.now()))))
                                .length
                                .toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ReportPage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(KIcons.quiz),
                    const SizedBox(width: 8.0),
                    Text(
                      '小テスト',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Expanded(child: SizedBox()),
                    snapshot.hasData
                        ? Text(
                            (snapshot.data![2] as List<Quiz>)
                                .where((e) => !(e.isArchived ||
                                    !(!e.isSubmitted &&
                                        e.endDateTime.isAfter(DateTime.now()))))
                                .length
                                .toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        : const SizedBox.shrink()
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const QuizPage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(KIcons.sharedFile),
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
                    Icon(KIcons.classLink),
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
                    Icon(KIcons.grade),
                    const SizedBox(width: 8.0),
                    Text(
                      '成績情報',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const GradePage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(KIcons.settings),
                    const SizedBox(width: 8.0),
                    Text(
                      '設定',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsWidget()));
                },
              ),
            ],
          ),
        );
      });
}

AppBar buildAppBar(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
    elevation: 0,
    leading: FutureBuilder(
      future: context.watch<SettingsRepository>().load(),
      builder: (context, AsyncSnapshot<Settings> snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    child: snapshot.data?.profileImage == null
                        ? const Icon(
                            LineIcons.user,
                            size: 36.0,
                          )
                        : CircleAvatar(
                            backgroundImage: CachedMemoryImageProvider(
                              'ProfileImage',
                              base64: snapshot.data?.profileImage,
                            ),
                          ),
                  ),
                ),
              )
            : const SizedBox.shrink();
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
                    ? 'アカウント情報なし'
                    : '${snapshot.data?.fullName}さん',
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(LineIcons.alternateSignIn),
                onPressed: () async =>
                    context.read<ApiRepository>().fetchLogin(),
              ),
              IconButton(
                icon: const Icon(LineIcons.syncIcon),
                onPressed: () async => showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text('更新'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchSubjects(),
                          child: const Text('授業科目'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchContacts(),
                          child: const Text('授業連絡'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchReports(),
                          child: const Text('レポート'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchQuizzes(),
                          child: const Text('小テスト'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchSharedFiles(),
                          child: const Text('授業共有ファイル'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchClassLinks(),
                          child: const Text('授業リンク'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchGrades(),
                          child: const Text('成績情報'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchTimetables(),
                          child: const Text('個人時間割'),
                        ),
                      ],
                    );
                  },
                ),
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

PreferredSize buildAppBarBottom(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(6.0),
    child: Visibility(
      visible: context.watch<ApiRepository>().isLoading,
      child: LinearProgressIndicator(
        minHeight: 3.0,
        valueColor: context.watch<ApiRepository>().isError
            ? AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.error)
            : AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
      ),
    ),
  );
}
