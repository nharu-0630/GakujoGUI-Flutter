import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gakujo_task/provide.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickyHeader(
            header: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: const Text(
                'アカウント',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            content: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Token: ${context.watch<Provide>().api.token} \nSubjects Items: ${context.watch<Provide>().api.subjects.length}\n Contacts Items: ${context.watch<Provide>().api.contacts.length}\n Reports Items: ${context.watch<Provide>().api.reports.length}\n Quizzes Items: ${context.watch<Provide>().api.quizzes.length}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<Provide>().loadSettings();
                      },
                      child: const Text('読み込み'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<Provide>().login();
                      },
                      child: const Text('ログイン'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<Provide>().fetchSubjects();
                      },
                      child: const Text('授業科目'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<Provide>().fetchContacts();
                      },
                      child: const Text('授業連絡'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<Provide>().fetchReports();
                      },
                      child: const Text('レポート'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<Provide>().fetchQuizzes();
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
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
