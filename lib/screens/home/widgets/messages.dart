import 'package:flutter/material.dart';
import 'package:gakujo_task/constants/colors.dart';
import 'package:gakujo_task/models/message.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/screens/message/message.dart';
import 'package:intl/intl.dart';

class Messages extends StatelessWidget {
  final subjects = Subject.generateSubjects();
  final messages = Message.generateMessages();

  Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          itemBuilder: ((context, index) => _buildMessages(context, index)),
        ));
  }

  Widget _buildMessages(BuildContext context, int index) {
    final subject = subjects[index];
    final message = messages
        .where(
          (element) => element.subject == subject.className,
        )
        .toList();
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MessagePage(subject, message)));
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
                    subject.className,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Align(
                    child: Text(
                  message.isNotEmpty
                      ? DateFormat('yyyy/MM/dd HH:mm', 'ja')
                          .format(message.last.contactDateTime.toLocal())
                      : '',
                  style: const TextStyle(color: kGreyLight),
                ))
              ],
            ),
            SizedBox(
              width: 300,
              child: Flexible(
                  child: Text(
                message.isNotEmpty
                    ? message.last.content.replaceAll('\n', ' ')
                    : 'メッセージなし',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ),
          ]),
        ));
  }
}
