import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:intl/intl.dart';
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
    return FutureBuilder(
      future: context
          .watch<ContactRepository>()
          .getSubjects(widget.subject.subjectsName),
      builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData) {
          snapshot.data!.sort(((a, b) => b.compareTo(a)));
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                snapshot.data!.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.message_rounded,
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
                                  (_, index) => _buildCard(
                                      context, _suggestContacts[index]),
                                  childCount: _suggestContacts.length,
                                )
                              : SliverChildBuilderDelegate(
                                  (_, index) => _buildCard(
                                      context, snapshot.data![index]),
                                  childCount: snapshot.data!.length,
                                ),
                        ),
                      )
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      floating: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      title: _searchStatus
          ? TextField(
              onChanged: (value) {
                setState(() async {
                  _suggestContacts = (await context
                          .read<ContactRepository>()
                          .getSubjects(widget.subject.subjectsName))
                      .where((e) => e.contains(value))
                      .toList();
                });
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
                icon: const Icon(Icons.close_rounded),
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
                icon: const Icon(Icons.search_rounded),
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
            icon: Icons.sync_rounded,
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
                return _buildModal(contact, controller);
              },
            ),
          );
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                contact.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
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
                contact.isAcquired
                    ? contact.content.replaceAll('\n', ' ')
                    : '未取得',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Visibility(
              visible: contact.fileNames?.isNotEmpty ?? false,
              child: const Icon(Icons.file_present_rounded),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModal(Contact contact, ScrollController controller) {
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
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(contact.contactDateTime.toLocal()),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
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
          child: buildAutoLinkText(
              context, contact.isAcquired ? contact.content : '未取得'),
        ),
        Visibility(
          visible: contact.fileNames?.isNotEmpty ?? false,
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Divider(thickness: 2.0),
          ),
        ),
        Visibility(
          visible: contact.fileNames?.isNotEmpty ?? false,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: buildFileList(contact.fileNames),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
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
