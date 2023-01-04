import 'package:flutter/material.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/contact/contact.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContactWidget extends StatelessWidget {
  const ContactWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var subjects = context.watch<ApiProvider>().api.subjects;
    var contacts = context.watch<ApiProvider>().api.contacts;
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
                      Icons.speaker_notes_off_rounded,
                      size: 24.0,
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
                  contacts
                      .where((e) => e.subjects == subjects[index].subjectsName)
                      .toList())),
            ),
    );
  }

  Widget _buildTile(
      BuildContext context, Subject subject, List<Contact> contacts) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ContactPage(subject)));
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
            contacts.isNotEmpty
                ? DateFormat('yyyy/MM/dd HH:mm', 'ja')
                    .format(contacts.first.contactDateTime.toLocal())
                : '',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
      subtitle: Text(
        contacts.isNotEmpty
            ? contacts.first.isAcquired
                ? contacts.first.content.replaceAll('\n', ' ')
                : '未取得'
            : 'メッセージなし',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
