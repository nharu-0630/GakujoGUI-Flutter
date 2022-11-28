import 'package:flutter/material.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/views/contact/contact.dart';

class ContactIcons extends StatelessWidget {
  final List<Subject> subjects;
  final List<Contact> contacts;

  const ContactIcons({Key? key, required this.subjects, required this.contacts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: subjects.length,
          itemBuilder: ((context, index) => _buildMessageIcon(context, index))),
    );
  }

  Widget _buildMessageIcon(BuildContext context, int index) {
    final subject = subjects[index];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ContactPage(
                subject,
                contacts
                    .where(
                        (element) => element.subjects == subject.subjectsName)
                    .toList())));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 60,
        decoration: BoxDecoration(
          color: subjects[index].subjectColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${subjects[index].subjectsName.substring(0, 1)}\n${subjects[index].subjectsName.substring(subjects[index].subjectsName.length - 1)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
