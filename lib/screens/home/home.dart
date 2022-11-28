import 'package:flutter/material.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/screens/home/widgets/message_icons.dart';
import 'package:gakujo_task/screens/home/widgets/messages.dart';
import 'package:gakujo_task/screens/home/widgets/status.dart';
import 'package:gakujo_task/screens/home/widgets/tasks.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomePage extends StatelessWidget {
  Api api;

  HomePage({Key? key, required this.api}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await api.login();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Status(),
              StickyHeader(
                header: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(15),
                  child: const Text(
                    'タスク',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                content: Tasks(),
              ),
              StickyHeader(
                  header: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          child: const Text(
                            'メッセージ',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                                height: 60,
                                child: Expanded(child: MessageIcons())),
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: Messages()),
              const SizedBox(height: 15)
            ],
          ),
        ));
  }
}
