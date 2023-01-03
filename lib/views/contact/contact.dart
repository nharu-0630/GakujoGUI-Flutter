import 'package:flutter/material.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:intl/intl.dart';

class ContactPage extends StatelessWidget {
  final Subject subject;
  final List<Contact> contacts;
  const ContactPage(this.subject, this.contacts, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          contacts.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.speaker_notes_off_rounded,
                            size: 48.0,
                          ),
                        ),
                        Text(
                          'メッセージはありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (_, index) => _buildCard(
                              context,
                              contacts[index],
                            ),
                        childCount: contacts.length),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new),
        iconSize: 24.0,
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          subject.subjectsName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(
            Icons.search,
            size: 32.0,
          ),
        )
      ],
    );
  }

  Widget _buildCard(BuildContext context, Contact contact) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              contact.content == null ? '未取得' : contact.content!,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('yyyy/MM/dd HH:mm', 'ja')
                    .format(contact.contactDateTime.toLocal()),
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
