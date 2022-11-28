import 'package:flutter/material.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:intl/intl.dart';

class ContactChat extends StatelessWidget {
  final Contact contact;
  const ContactChat(this.contact, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(children: [
        Expanded(
        child: _buildCard(contact),
        )
      ]),
    );
  }

  Widget _buildCard(Contact contact) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
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
                Text(contact.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(contact.content!),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            DateFormat('yyyy/MM/dd HH:mm', 'ja')
                .format(contact.contactDateTime.toLocal()),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
