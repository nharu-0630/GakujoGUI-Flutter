import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/provide.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ContactPage extends StatefulWidget {
  final Subject subject;
  const ContactPage(this.subject, {Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _searchStatus = false;
  List<Contact> _suggestContacts = [];

  @override
  Widget build(BuildContext context) {
    final List<Contact> contacts = context
        .watch<ApiProvider>()
        .api
        .contacts
        .where(
          (e) => e.subjects == widget.subject.subjectsName,
        )
        .toList();
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
                    delegate: _searchStatus
                        ? SliverChildBuilderDelegate(
                            (_, index) =>
                                _buildCard(context, _suggestContacts[index]),
                            childCount: _suggestContacts.length,
                          )
                        : SliverChildBuilderDelegate(
                            (_, index) => _buildCard(context, contacts[index]),
                            childCount: contacts.length,
                          ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      title: _searchStatus
          ? TextField(
              onChanged: (value) {
                setState(() => _suggestContacts = context
                    .read<ApiProvider>()
                    .api
                    .contacts
                    .where(
                      (e) => e.subjects == widget.subject.subjectsName,
                    )
                    .where((e) => e.contains(value))
                    .toList());
              },
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : Text(widget.subject.subjectsName),
      actions: _searchStatus
          ? [
              IconButton(
                onPressed: (() {
                  setState(() {
                    _searchStatus = false;
                  });
                }),
                icon: const Icon(Icons.close),
              ),
            ]
          : [
              IconButton(
                onPressed: (() {
                  setState(() {
                    _searchStatus = true;
                    _suggestContacts = [];
                  });
                }),
                icon: const Icon(Icons.search),
              ),
            ],
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCard(BuildContext context, Contact contact) {
    return Slidable(
      key: Key(contact.hashCode.toString()),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async =>
                context.read<ApiProvider>().fetchDetailContact(contact),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.sync,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (!contact.isAcquired) {
            await showDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                content: const Text('未取得の授業です。取得しますか？'),
                actions: [
                  CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('キャンセル')),
                  CupertinoDialogAction(
                    child: const Text('取得'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<ApiProvider>().fetchDetailContact(contact);
                    },
                  )
                ],
              ),
            );
          }
          showModalBottomSheet(
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16.0))),
            context: context,
            builder: (context) => DraggableScrollableSheet(
              expand: false,
              builder: (context, controller) {
                return _buildModal(context, contact, controller);
              },
            ),
          );
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                contact.subjects,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(contact.contactDateTime.toLocal()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                contact.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModal(
      BuildContext context, Contact contact, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              contact.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                DateFormat('yyyy/MM/dd HH:mm', 'ja')
                    .format(contact.targetDateTime.toLocal()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                DateFormat('yyyy/MM/dd HH:mm', 'ja')
                    .format(contact.contactDateTime.toLocal()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 4.0,
                ),
                child: Text(
                  contact.contactType,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SelectableText(
            contact.isAcquired ? contact.content : '未取得',
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Visibility(
          visible: contact.fileNames?.isNotEmpty ?? false,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contact.fileNames?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(basename(contact.fileNames![index])),
                  onTap: () async {
                    var file = File(contact.fileNames![index]);
                    print(file.path);
                    print(await file.exists());
                    OpenFile.open(contact.fileNames![index]);
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async =>
                      context.read<ApiProvider>().fetchDetailContact(contact),
                  child: const Icon(Icons.sync_rounded),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () =>
                      Share.share(contact.content, subject: contact.title),
                  child: const Icon(Icons.share_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
