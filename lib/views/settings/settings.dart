import 'package:flutter/material.dart';
import 'package:gakujo_task/provide.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickyHeader(
            header: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: const Text(
                'アカウント',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            content: const Text(''),
          ),
          // const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Token: ${context.watch<Provide>().token}\nContacts Items: ${context.watch<Provide>().contacts.length}\nSubjects Items: ${context.watch<Provide>().subjects.length}',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
