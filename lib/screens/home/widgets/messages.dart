import 'package:flutter/material.dart';
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
              crossAxisCount: 1, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemBuilder: ((context, index) => _buildMessages()),
        ));
  }

  Widget _buildMessages() {
    return const Text('data');
  }
}
