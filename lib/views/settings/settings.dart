import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/provide.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  var _username = '';
  var _password = '';
  var _year = '';
  var _semester = '';

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<ApiProvider>().api.settings;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          StickyHeader(
            header: Container(
              width: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(16),
              child: Text(
                'アカウント',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            content: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '静大ID',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: TextField(
                            controller:
                                TextEditingController(text: settings.username),
                            onChanged: (value) => _username = value,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'パスワード',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: TextField(
                            controller:
                                TextEditingController(text: settings.password),
                            obscureText: true,
                            onChanged: (value) => _password = value,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () async {
                      setState(() {
                        context
                            .read<ApiProvider>()
                            .setUserInfo(_username, _password);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '取得年度',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: TextField(
                            controller: TextEditingController(
                                text: settings.year.toString()),
                            onChanged: (value) => _year = value,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '取得学期',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: TextField(
                            controller: TextEditingController(
                                text: settings.semester.toString()),
                            onChanged: (value) => _semester = value,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () async {
                      setState(() {
                        context.read<ApiProvider>().setSemester(
                            int.tryParse(_year), int.tryParse(_semester));
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.input_rounded),
                          const SizedBox(width: 8.0),
                          Text(
                            '読込',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Token: ${context.watch<ApiProvider>().api.token} \nAccessEnvironmentName: ${settings.accessEnvironmentName} \nAccessEnvironmentKey: ${settings.accessEnvironmentKey} \nAccessEnvironmentValue: ${settings.accessEnvironmentValue} \nUsername: ${context.watch<ApiProvider>().api.settings.username} \nYear: ${settings.year} \nSemester: ${settings.semester} ',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: const Divider(thickness: 2.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FutureBuilder(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            'Client Version: \nAPI Version: ',
                          );
                        }
                        return Text(
                          'Client Version: ${snapshot.data!.version}\nAPI Version: ${Api.version}',
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          content: const Text('一括更新には時間がかかります。更新しますか？'),
                          actions: [
                            CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('キャンセル')),
                            CupertinoDialogAction(
                              child: const Text('取得'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.read<ApiProvider>().fetchAll();
                              },
                            )
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sync_rounded),
                          const SizedBox(width: 8.0),
                          Text(
                            '一括更新',
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
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          content: const Text('初期化するとすべてのデータが削除されます。初期化しますか？'),
                          actions: [
                            CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('キャンセル')),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('初期化'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.read<ApiProvider>().clearSettings();
                              },
                            )
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_rounded),
                          const SizedBox(width: 8.0),
                          Text(
                            '初期化',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onError),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
