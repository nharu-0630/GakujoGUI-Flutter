import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                child: Text(
                  'Token: ${context.watch<ApiProvider>().api.token} \nSubjects Items: ${context.watch<ApiProvider>().api.subjects.length}\n Contacts Items: ${context.watch<ApiProvider>().api.contacts.length}\n Reports Items: ${context.watch<ApiProvider>().api.reports.length}\n Quizzes Items: ${context.watch<ApiProvider>().api.quizzes.length}',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ApiProvider>().loadSettings();
                  },
                  child: const Text('読み込み'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ApiProvider>().fetchLogin();
                  },
                  child: const Text('ログイン'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ApiProvider>().fetchSubjects();
                  },
                  child: const Text('授業科目'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ApiProvider>().fetchContacts();
                  },
                  child: const Text('授業連絡'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ApiProvider>().fetchReports();
                  },
                  child: const Text('レポート'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ApiProvider>().fetchQuizzes();
                  },
                  child: const Text('小テスト'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: 'テスト',
                        toastLength: Toast.LENGTH_LONG,
                        timeInSecForIosWeb: 5,
                        fontSize: 16.0);
                  },
                  child: const Text('テスト'),
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
