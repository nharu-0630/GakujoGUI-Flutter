import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/settings.dart';
import 'package:gakujo_gui/views/page/class_link.dart';
import 'package:gakujo_gui/views/page/grade.dart';
import 'package:gakujo_gui/views/page/quiz.dart';
import 'package:gakujo_gui/views/page/report.dart';
import 'package:gakujo_gui/views/page/settings.dart';
import 'package:gakujo_gui/views/page/shared_file.dart';
import 'package:gakujo_gui/views/page/syllabus_search.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

Widget? buildFloatingActionButton(
        {required Function() onPressed, required IconData iconData}) =>
    (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
        ? FloatingActionButton(
            onPressed: () async => onPressed(),
            child: Icon(iconData),
          )
        : null;

Flash buildErrorFlashBar(
    BuildContext context, FlashController<Object?> controller, Object? e) {
  return Flash(
    controller: controller,
    behavior: FlashBehavior.floating,
    position: FlashPosition.bottom,
    backgroundColor: Theme.of(context).colorScheme.onError,
    child: FlashBar(
      icon: Icon(
        LineIcons.exclamationTriangle,
        color: Theme.of(context).colorScheme.error,
      ),
      primaryAction: IconButton(
        onPressed: () => controller.dismiss(),
        icon: Icon(
          KIcons.close,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      title: Text(
        'エラー',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(
        e.toString(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  );
}

Flash buildInfoFlashBar(
    BuildContext context, FlashController<Object?> controller,
    {String? title, required String content}) {
  return Flash(
    controller: controller,
    behavior: FlashBehavior.floating,
    position: FlashPosition.bottom,
    backgroundColor: Theme.of(context).colorScheme.onSecondary,
    child: FlashBar(
      icon: Icon(
        LineIcons.infoCircle,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: title != null
          ? Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            )
          : null,
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  );
}

Widget buildFileList(List<String>? fileNames,
    {Axis scrollDirection = Axis.vertical}) {
  return fileNames?.isNotEmpty ?? false
      ? ListView.builder(
          scrollDirection: scrollDirection,
          padding: const EdgeInsets.all(0.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fileNames!.length,
          itemBuilder: (context, index) => ListTile(
            title: Row(
              children: [
                _buildExtIcon(
                    p.extension(fileNames[index]).replaceFirst('.', '')),
                const SizedBox(width: 8.0),
                Text(p.basename(fileNames[index])),
              ],
            ),
            onTap: () async => _openFile(fileNames[index]),
          ),
        )
      : const SizedBox.shrink();
}

void _openFile(String filename) async {
  var path = p.join((await getApplicationDocumentsDirectory()).path, filename);
  if (File(path).existsSync()) {
    OpenFile.open(path);
  } else {
    showFlash(
      context: App.navigatorKey.currentState!.overlay!.context,
      builder: (context, controller) =>
          buildErrorFlashBar(context, controller, 'ファイルが存在しません'),
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
    linkStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
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
        var settings = (snapshot.data?[0] as Settings?);
        var reports = (snapshot.data?[1] as List<Report>?);
        var reportCount = reports
                ?.where((e) => !(e.isArchived ||
                    !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now()))))
                .length ??
            0;
        var quizzes = (snapshot.data?[2] as List<Quiz>?);
        var quizCount = quizzes
                ?.where((e) => !(e.isArchived ||
                    !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now()))))
                .length ??
            0;
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
                      settings != null
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(LineIcons.userClock),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      settings.lastLoginTime
                                          .toLocal()
                                          .toDetailString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    const Icon(LineIcons.identificationBadge),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      settings.username ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    const Icon(LineIcons.userShield),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      settings.accessEnvironmentName ?? '',
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
                    reportCount > 0
                        ? Badge(
                            label: Text(reportCount.toString()),
                            backgroundColor:
                                Theme.of(context).colorScheme.onError,
                            textColor: Theme.of(context).colorScheme.error,
                            child: Icon(
                              KIcons.report,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          )
                        : Icon(
                            KIcons.report,
                            color: Theme.of(context).iconTheme.color,
                          ),
                    const SizedBox(width: 8.0),
                    Text(
                      'レポート',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                    quizCount > 0
                        ? Badge(
                            label: Text(quizCount.toString()),
                            backgroundColor:
                                Theme.of(context).colorScheme.onError,
                            textColor: Theme.of(context).colorScheme.error,
                            child: Icon(
                              KIcons.quiz,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          )
                        : Icon(
                            KIcons.quiz,
                            color: Theme.of(context).iconTheme.color,
                          ),
                    const SizedBox(width: 8.0),
                    Text(
                      '小テスト',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                    Icon(
                      KIcons.sharedFile,
                      color: Theme.of(context).iconTheme.color,
                    ),
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
                    Icon(
                      KIcons.classLink,
                      color: Theme.of(context).iconTheme.color,
                    ),
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
                    Icon(
                      KIcons.grade,
                      color: Theme.of(context).iconTheme.color,
                    ),
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
                    Icon(
                      KIcons.syllabus,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'シラバス',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SyllabusSearchPage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(
                      KIcons.settings,
                      color: Theme.of(context).iconTheme.color,
                    ),
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
                      builder: (context) => const SettingsPage()));
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
      builder: (context, AsyncSnapshot<Settings> snapshot) => snapshot.hasData
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: snapshot.data?.profileImage != null
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => scaffoldKey.currentState?.openDrawer(),
                        child: CircleAvatar(
                          backgroundImage: CachedMemoryImageProvider(
                            'ProfileImage',
                            base64: snapshot.data?.profileImage,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(LineIcons.user),
                    ),
            )
          : const SizedBox.shrink(),
    ),
    centerTitle: false,
    title: FutureBuilder(
      future: context.watch<SettingsRepository>().load(),
      builder: (context, AsyncSnapshot<Settings> snapshot) => Text(
        snapshot.hasData
            ? snapshot.data?.fullName == null
                ? 'アカウント情報なし'
                : '${snapshot.data?.fullName}さん'
            : 'アカウント情報なし',
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(LineIcons.alternateSignIn),
          onPressed: () async => context.read<ApiRepository>().fetchLogin(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(KIcons.update),
          onPressed: () async => showDialog(
            context: App.navigatorKey.currentState!.overlay!.context,
            builder: (context) => SimpleDialog(
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
            ),
          ),
        ),
      ),
    ],
    bottom: buildAppBarBottom(context),
  );
}

PreferredSize buildAppBarBottom(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(6.0),
    child: Builder(
        builder: (context) => Visibility(
              visible: context.watch<ApiRepository>().isLoading,
              child: LinearProgressIndicator(
                minHeight: 3.0,
                valueColor: context.watch<ApiRepository>().isError
                    ? AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.error)
                    : AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                value: context.watch<ApiRepository>().progress != -1
                    ? context.watch<ApiRepository>().progress
                    : null,
              ),
            )),
  );
}
