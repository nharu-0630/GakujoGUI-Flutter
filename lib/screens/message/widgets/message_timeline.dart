import 'package:flutter/material.dart';
import 'package:gakujo_task/models/message.dart';

class MessageTimeline extends StatelessWidget {
  final Message message;
  const MessageTimeline(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(children: [
        Expanded(
          child: _buildCard(message),
        )
      ]),
    );
  }

  Widget _buildCard(Message message) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(message.content),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            message.contactDateTime.toString(),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
