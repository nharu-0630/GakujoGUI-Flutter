import 'package:flutter/material.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/views/contact/contact.dart';
import 'package:intl/intl.dart';

class ContactWidget extends StatelessWidget {
  ContactWidget({Key? key}) : super(key: key);

  final List<Subject> subjects = [];
  final List<Contact> contacts = [];

  @override
  Widget build(BuildContext context) {
    subjects.addAll(
      [
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white),
        Subject('subjectsName', 'teacherName', 'classRoom', Colors.white)
      ],
    );
    contacts.addAll([
      Contact('subjectsName', 'teacherName', '', 'title', null, null, null,
          null, null, null, DateTime.now(), DateTime.now(), null,
          isAcquired: false),
    ]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subjects.length,
        itemBuilder: ((context, index) => _buildContactTile(
            context,
            subjects[index],
            contacts
                .where((e) => e.subjects == subjects[index].subjectsName)
                .toList())),
      ),
    );
  }

  Widget _buildContactTile(
      BuildContext context, Subject subject, List<Contact> contacts) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ContactPage(subject, contacts)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                          .format(contacts.last.contactDateTime.toLocal())
                      : '',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              contacts.isNotEmpty
                  ? contacts.last.content != null
                      ? contacts.last.content!.replaceAll('\n', ' ')
                      : '未取得'
                  : 'メッセージなし',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
