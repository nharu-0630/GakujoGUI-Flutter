import 'package:flutter/material.dart';
import 'package:gakujo_task/constants/colors.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/views/contact/contact.dart';
import 'package:intl/intl.dart';

class ContactTimeLine extends StatelessWidget {
  final List<Subject> subjects;
  final List<Contact> contacts;

  const ContactTimeLine(
      {Key? key, required this.subjects, required this.contacts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          itemBuilder: ((context, index) => _buildMessage(context, index)),
        ));
  }

  Widget _buildMessage(BuildContext context, int index) {
    final subject = subjects[index];
    List<Contact> contact = contacts
        .where((element) => element.subjects == subject.subjectsName)
        .toList();

    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ContactPage(subject, contact)));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    subject.subjectsName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Align(
                    child: Text(
                  contact.isNotEmpty
                      ? DateFormat('yyyy/MM/dd HH:mm', 'ja')
                          .format(contact.last.contactDateTime.toLocal())
                      : '',
                  style: const TextStyle(color: kGreyLight),
                ))
              ],
            ),
            SizedBox(
              width: 300,
              child: Flexible(
                  child: Text(
                contact.isNotEmpty
                    ? contact.last.content!.replaceAll('\n', ' ')
                    : 'メッセージなし',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ),
          ]),
        ));
  }
}
