import 'package:flutter/material.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/home/widgets/contact_icons.dart';
import 'package:gakujo_task/views/home/widgets/contact_timeline.dart';
import 'package:gakujo_task/views/home/widgets/status.dart';
import 'package:gakujo_task/views/home/widgets/tasks.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          context.read<Provide>().login();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                content: const Tasks(),
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
                                child: ContactIcons(
                                  subjects:
                                      context.watch<Provide>().api.subjects,
                                  contacts:
                                      context.watch<Provide>().api.contacts,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: ContactTimeLine(
                    subjects: context.watch<Provide>().api.subjects,
                    contacts: context.watch<Provide>().api.contacts,
                  )),
              const SizedBox(height: 15),
            ],
          ),
        ));
  }
}
