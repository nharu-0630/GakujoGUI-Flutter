import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/subject.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:side_sheet/side_sheet.dart';

class ContactPage extends StatefulWidget {
  final Subject subject;
  const ContactPage(this.subject, {Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _searchStatus = false;
  List<Contact> _contacts = [];
  List<Contact> _suggestContacts = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context
          .watch<ContactRepository>()
          .getSubjects(widget.subject.subject),
      builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData) {
          _contacts = snapshot.data!;
          _contacts.sort(((a, b) => b.compareTo(a)));
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                _contacts.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  KIcons.contact,
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
                                  (_, index) =>
                                      _buildCard(context, _contacts[index]),
                                  childCount: _contacts.length,
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
          icon: Icon(KIcons.back),
        ),
      ),
      title: _searchStatus
          ? TextField(
              onChanged: (value) => setState(() => _suggestContacts =
                  _contacts.where((e) => e.contains(value)).toList()),
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : Text(widget.subject.subject),
      actions: _searchStatus
          ? [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() => setState(() => _searchStatus = false)),
                  icon: Icon(KIcons.close),
                ),
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() => setState(() {
                        _searchStatus = true;
                        _suggestContacts = [];
                      })),
                  icon: Icon(KIcons.search),
                ),
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
                context.read<ApiRepository>().fetchDetailContact(contact),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: KIcons.update,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (contact.isAcquired) {
            MediaQuery.of(context).orientation == Orientation.portrait
                ? showModalBottomSheet(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    isScrollControlled: false,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(0.0))),
                    context: context,
                    builder: (context) => buildContact(context, contact),
                  )
                : SideSheet.right(
                    sheetColor: Theme.of(context).colorScheme.surface,
                    body: SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      child: buildContact(context, contact),
                    ),
                    context: context,
                  );
          } else {
            await showOkCancelAlertDialog(
                      context: context,
                      title: '未取得の授業連絡です。',
                      message: '取得しますか？',
                      okLabel: '取得',
                      cancelLabel: 'キャンセル',
                    ) ==
                    OkCancelResult.ok
                ? context.read<ApiRepository>().fetchDetailContact(contact)
                : null;
          }
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: contact.severity == '重要',
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(KIcons.important),
              ),
            ),
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
              contact.contactDateTime.toLocal().toDetailString(),
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
              child: Text(
                '${contact.fileNames?.length ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Visibility(
              visible: contact.fileNames?.isNotEmpty ?? false,
              child: Icon(KIcons.attachment),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContact(BuildContext context, Contact contact) {
    return ListView(
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
              contact.contactDateTime.toLocal().toDetailString(),
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
                      context.read<ApiRepository>().fetchDetailContact(contact),
                  child: Icon(KIcons.update),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () =>
                      Share.share(contact.content, subject: contact.title),
                  child: Icon(KIcons.share),
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
