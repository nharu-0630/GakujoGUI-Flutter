import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/provide.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Token: ${context.watch<ApiProvider>().api.token} \nSubjects Items: ${context.watch<ApiProvider>().api.subjects.length}\n Contacts Items: ${context.watch<ApiProvider>().api.contacts.length}\n Reports Items: ${context.watch<ApiProvider>().api.reports.length}\n Quizzes Items: ${context.watch<ApiProvider>().api.quizzes.length}',
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
                        const Icon(Icons.sync),
                        const SizedBox(width: 8.0),
                        Text(
                          '一括更新',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
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
                        const Icon(Icons.delete),
                        const SizedBox(width: 8.0),
                        Text(
                          '初期化',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.onError),
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
    );
  }
}
