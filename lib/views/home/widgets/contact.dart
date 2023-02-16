import 'package:flutter/material.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/contact_repository.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/contact/contact.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContactWidget extends StatelessWidget {
  const ContactWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var subjects = context.watch<ApiProvider>().subjects;
    return FutureBuilder(
      future: context.read<ContactRepository>().getAll(),
      builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData) {
          // subjects.sort((a, b) {
          //   var aContact =
          //       snapshot.data!.firstWhere((e) => e.subjects == a.subjectsName);
          //   var bContact =
          //       snapshot.data!.firstWhere((e) => e.subjects == b.subjectsName);
          //   return bContact.contactDateTime.compareTo(aContact.contactDateTime);
          // });
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: subjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.message_rounded,
                            size: 32.0,
                          ),
                        ),
                        Text(
                          'メッセージはありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjects.length,
                    itemBuilder: ((context, index) => _buildTile(
                          context,
                          subjects[index],
                        )),
                  ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildTile(BuildContext context, Subject subject) {
    return FutureBuilder(
      future:
          context.read<ContactRepository>().getSubjects(subject.subjectsName),
      builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ContactPage(subject)));
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    subject.subjectsName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  snapshot.data!.isNotEmpty
                      ? DateFormat('yyyy/MM/dd HH:mm', 'ja').format(
                          snapshot.data!.first.contactDateTime.toLocal())
                      : '',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              ],
            ),
            subtitle: Text(
              snapshot.data!.isNotEmpty
                  ? snapshot.data!.first.isAcquired
                      ? snapshot.data!.first.content.replaceAll('\n', ' ')
                      : '未取得'
                  : 'メッセージなし',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
