import 'package:flutter/material.dart';
import 'package:gakujo_task/constants/colors.dart';
import 'package:gakujo_task/models/message.dart';

class Messages extends StatelessWidget {
  final messageList = Message.generateMessages();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: messageList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 5,
              crossAxisCount: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: ((context, index) => _buildMessages(index)),
        ));
  }

  Widget _buildMessages(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                messageList[index].subject.className,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Align(
                child: Text(
              messageList[index].lastTime,
              style: const TextStyle(color: kGreyLight),
            ))
          ],
        ),
        SizedBox(
          width: 300,
          child: Flexible(
              child: Text(
            messageList[index].lastMessage.replaceAll('\n', ' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ),
      ]),
    );
  }
}
