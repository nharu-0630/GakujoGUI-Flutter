import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/gakujo_api.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/api/syllabus_api.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/class_link.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/grade.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/settings.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/models/subject.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  var _isObscure = true;

  @override
  void initState() {
    super.initState();
    initValue();
  }

  void initValue() {
    App.navigatorKey.currentContext?.watch<SettingsRepository>().load().then(
      (value) {
        setState(
          () {
            _usernameController =
                TextEditingController(text: value.username ?? '');
            _passwordController =
                TextEditingController(text: value.password ?? '');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder(
        future: Future.wait([
          context.watch<SettingsRepository>().load(),
          PackageInfo.fromPlatform()
        ]),
        builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
          var settings = (snapshot.data?[0] as Settings?);
          var packageInfo = (snapshot.data?[1] as PackageInfo?);
          return settings != null && packageInfo != null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    StickyHeader(
                      header: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(LineIcons.userCog),
                            const SizedBox(width: 8.0),
                            Text(
                              'アカウント',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '静大ID',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                      controller: _usernameController),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'パスワード',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _isObscure,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        icon: Icon(_isObscure
                                            ? LineIcons.eyeSlash
                                            : LineIcons.eye),
                                        onPressed: () => setState(
                                            () => _isObscure = !_isObscure),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed: () async {
                                  context
                                      .read<SettingsRepository>()
                                      .setUsername(_usernameController.text);
                                  context
                                      .read<SettingsRepository>()
                                      .setPassword(_passwordController.text);
                                  showFlash(
                                    context: App.navigatorKey.currentState!
                                        .overlay!.context,
                                    duration: const Duration(seconds: 3),
                                    builder: (context, controller) =>
                                        buildInfoFlashBar(context, controller,
                                            content: 'ログイン情報を保存しました'),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LineIcons.save),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        '保存',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Divider(thickness: 2.0),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '取得年度',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextButton(
                                      child: Text(
                                        settings.year?.toString() ?? '-',
                                      ),
                                      onPressed: () async => showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text('取得年度'),
                                          content: SizedBox(
                                            width: 360,
                                            height: 360,
                                            child: YearPicker(
                                              firstDate: DateTime(
                                                  DateTime.now().year - 5, 1),
                                              lastDate: DateTime(
                                                  DateTime.now().year + 5, 1),
                                              initialDate: settings.year == null
                                                  ? DateTime.now()
                                                  : DateTime(settings.year!),
                                              selectedDate: settings.year ==
                                                      null
                                                  ? DateTime.now()
                                                  : DateTime(settings.year!),
                                              onChanged: (DateTime dateTime) {
                                                context
                                                    .read<SettingsRepository>()
                                                    .setYear(dateTime.year);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '取得学期',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextButton(
                                      child: Text(
                                        (() {
                                          switch (settings.semester) {
                                            case 0:
                                              return '前期前半';
                                            case 1:
                                              return '前期後半';
                                            case 2:
                                              return '後期前半';
                                            case 3:
                                              return '後期後半';
                                            default:
                                              return '-';
                                          }
                                        })(),
                                      ),
                                      onPressed: () async => showDialog(
                                        context: context,
                                        builder: (context) => SimpleDialog(
                                          title: const Text('取得学期'),
                                          children: [
                                            SimpleDialogOption(
                                              onPressed: () async {
                                                context
                                                    .read<SettingsRepository>()
                                                    .setSemester(0);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('前期前半'),
                                            ),
                                            SimpleDialogOption(
                                              onPressed: () async {
                                                context
                                                    .read<SettingsRepository>()
                                                    .setSemester(1);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('前期後半'),
                                            ),
                                            SimpleDialogOption(
                                              onPressed: () async {
                                                context
                                                    .read<SettingsRepository>()
                                                    .setSemester(2);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('後期前半'),
                                            ),
                                            SimpleDialogOption(
                                              onPressed: () async {
                                                context
                                                    .read<SettingsRepository>()
                                                    .setSemester(3);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('後期後半'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Divider(thickness: 2.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed: () async {
                                  await showOkCancelAlertDialog(
                                            context: context,
                                            message: '実行しますか？',
                                            okLabel: '実行',
                                            cancelLabel: 'キャンセル',
                                          ) ==
                                          OkCancelResult.ok
                                      ? context
                                          .read<ApiRepository>()
                                          .fetchLogin()
                                      : null;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LineIcons.alternateSignIn),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'ログイン',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onError,
                                ),
                                onPressed: () async {
                                  var result = await showOkCancelAlertDialog(
                                    isDestructiveAction: true,
                                    context: context,
                                    title: '初期化するとすべてのデータが削除されます。',
                                    message: '初期化しますか？',
                                    okLabel: '初期化',
                                    cancelLabel: 'キャンセル',
                                  );
                                  if (result == OkCancelResult.ok) {
                                    {
                                      App.navigatorKey.currentContext
                                          ?.read<ContactRepository>()
                                          .deleteAll();
                                      App.navigatorKey.currentContext
                                          ?.read<SubjectRepository>()
                                          .deleteAll();
                                      App.navigatorKey.currentContext
                                          ?.read<SettingsRepository>()
                                          .delete();
                                      App.navigatorKey.currentContext
                                          ?.read<ReportRepository>()
                                          .deleteAll();
                                      App.navigatorKey.currentContext
                                          ?.read<QuizRepository>()
                                          .deleteAll();
                                      App.navigatorKey.currentContext
                                          ?.read<GradeRepository>()
                                          .deleteAll();
                                      App.navigatorKey.currentContext
                                          ?.read<SharedFileRepository>()
                                          .deleteAll();
                                      App.navigatorKey.currentContext
                                          ?.read<ClassLinkRepository>()
                                          .deleteAll();
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LineIcons.trash),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        '初期化',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StickyHeader(
                      header: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(LineIcons.terminal),
                            const SizedBox(width: 8.0),
                            Text(
                              '開発者向け',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: buildAutoLinkText(
                                    'Client Version: ${packageInfo.version}\nGakujoAPI Version: ${GakujoApi.version}\nSyllabusAPI Version: ${SyllabusApi.version}\nToken: ${context.read<ApiRepository>().token}\nAccessEnvironment Key: ${settings.accessEnvironmentKey}\nAccessEnvironment Value: ${settings.accessEnvironmentValue}'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onError,
                                ),
                                onPressed: () async {
                                  var result = await showOkCancelAlertDialog(
                                    isDestructiveAction: true,
                                    context: context,
                                    title: 'Cookiesを削除すると環境登録が解除されます。',
                                    message: '削除しますか？',
                                    okLabel: '削除',
                                    cancelLabel: 'キャンセル',
                                  );
                                  if (result == OkCancelResult.ok) {
                                    {
                                      App.navigatorKey.currentContext
                                          ?.read<ApiRepository>()
                                          .clearCookies();
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LineIcons.trash),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'Cookiesを削除',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      title: const Text('設定'),
      bottom: buildAppBarBottom(),
    );
  }
}
