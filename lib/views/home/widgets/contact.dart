import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/subject.dart';
import 'package:gakujo_gui/views/page/contact.dart';
import 'package:provider/provider.dart';

class ContactWidget extends StatelessWidget {
  const ContactWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.watch<SubjectRepository>().getAll(),
        context.watch<ContactRepository>().getAll()
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          var subjects = snapshot.data![0] as List<Subject>;
          var contacts = snapshot.data![1] as List<Contact>;
          subjects.sort((a, b) {
            var aContact =
                contacts.firstWhereOrNull((e) => e.subject == a.subject);
            var bContact =
                contacts.firstWhereOrNull((e) => e.subject == b.subject);
            if (aContact == null || bContact == null) return 0;
            return bContact.contactDateTime.compareTo(aContact.contactDateTime);
          });
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: subjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            KIcons.contact,
                            size: 32.0,
                          ),
                        ),
                        Text(
                          'メッセージはありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjects.length,
                    itemBuilder: ((context, index) => _buildTile(
                          context,
                          subjects[index],
                          contacts
                              .where(
                                  (e) => e.subject == subjects[index].subject)
                              .toList(),
                        )),
                  ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildTile(
      BuildContext context, Subject subject, List<Contact> contacts) {
    return ListTile(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ContactPage(subject))),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              subject.subject,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            contacts.isNotEmpty
                ? contacts.first.contactDateTime.toLocal().toDetailString()
                : '',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
      subtitle: Text(
        contacts.isNotEmpty
            ? contacts.first.isAcquired
                ? contacts.first.content.replaceAll('\n', ' ')
                : '未取得'
            : 'メッセージなし',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
