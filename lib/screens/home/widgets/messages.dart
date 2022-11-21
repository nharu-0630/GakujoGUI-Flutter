import 'package:flutter/material.dart';
import 'package:gakujo_task/constants/colors.dart';
import 'package:gakujo_task/models/message.dart';
import 'package:gakujo_task/screens/message/message.dart';

class Messages extends StatelessWidget {
  final messageMap = Message.generateMessages();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: messageMap.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 5,
              crossAxisCount: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: ((context, index) => _buildMessages(context, index)),
        ));
  }

  Widget _buildMessages(BuildContext context, int index) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MessagePage(
                  messageMap.keys.elementAt(index),
                  messageMap.values.elementAt(index))));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    messageMap.keys.elementAt(index).className,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Align(
                    child: Text(
                  messageMap.values.elementAt(index).last.dateTime,
                  style: const TextStyle(color: kGreyLight),
                ))
              ],
            ),
            SizedBox(
              width: 300,
              child: Flexible(
                  child: Text(
                messageMap.values
                    .elementAt(index)
                    .last
                    .content
                    .replaceAll('\n', ' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ),
          ]),
        ));
  }
}
