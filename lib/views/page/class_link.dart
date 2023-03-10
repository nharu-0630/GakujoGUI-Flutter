import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/models/class_link.dart';
import 'package:gakujo_task/models/shared_file.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ClassLinkPage extends StatefulWidget {
  const ClassLinkPage({Key? key}) : super(key: key);

  @override
  State<ClassLinkPage> createState() => _ClassLinkPageState();
}

class _ClassLinkPageState extends State<ClassLinkPage> {
  bool _searchStatus = false;
  bool _filterStatus = false;
  List<ClassLink> _classLinks = [];
  List<ClassLink> _suggestClassLinks = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<ClassLinkRepository>().getAll(),
      builder: (context, AsyncSnapshot<List<ClassLink>> snapshot) {
        if (snapshot.hasData) {
          _classLinks = snapshot.data!;
          _classLinks.sort(((a, b) => b.compareTo(a)));
          var filteredClassLinks = _classLinks
              .where((e) => _filterStatus ? !e.isArchived : true)
              .toList();
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) =>
                  [_buildAppBar(context)],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchClassLinks(),
                child: filteredClassLinks.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.link_rounded,
                                      size: 48.0,
                                    ),
                                  ),
                                  Text(
                                    '授業リンクはありません',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _searchStatus
                            ? _suggestClassLinks.length
                            : _classLinks.length,
                        itemBuilder: (context, index) => _searchStatus
                            ? _buildCard(context, _suggestClassLinks[index])
                            : _buildCard(context, _classLinks[index]),
                      ),
              ),
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
              onChanged: (value) => setState(() => _suggestClassLinks =
                  _classLinks.where((e) => e.contains(value)).toList()),
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : const Text('授業リンク'),
      actions: _searchStatus
          ? [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() => setState(() => _searchStatus = false)),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() =>
                      setState(() => _filterStatus = !_filterStatus)),
                  icon: Icon(_filterStatus
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_off_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() => setState(() {
                        _searchStatus = true;
                        _suggestClassLinks = [];
                      })),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCard(BuildContext context, ClassLink classLink) {
    return Slidable(
      key: Key(classLink.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => context
                .read<SharedFileRepository>()
                .setArchive(classLink.id, !classLink.isArchived)
                .then((value) => setState(() {})),
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: classLink.isArchived
                ? Icons.unarchive_rounded
                : Icons.archive_rounded,
            label: classLink.isArchived ? 'アーカイブ解除' : 'アーカイブ',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async =>
                context.read<ApiRepository>().fetchDetailClassLink(classLink),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.sync_rounded,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (classLink.isAcquired) {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              context: context,
              builder: (context) => DraggableScrollableSheet(
                expand: false,
                builder: (context, controller) {
                  return buildClassLinkModal(context, classLink, controller);
                },
              ),
            );
          } else {
            await showOkCancelAlertDialog(
                      context: context,
                      title: '未取得の授業リンクです。',
                      message: '取得しますか？',
                      okLabel: '取得',
                      cancelLabel: 'キャンセル',
                    ) ==
                    OkCancelResult.ok
                ? context.read<ApiRepository>().fetchDetailClassLink(classLink)
                : null;
          }
        },
        title: Row(
          children: [
            Expanded(
              child: Text(
                classLink.subject,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    classLink.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Visibility(
                  visible: classLink.isArchived,
                  child: const Icon(Icons.archive_rounded),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildClassLinkModal(
    BuildContext context, ClassLink classLink, ScrollController controller) {
  return ListView(
    controller: controller,
    padding: const EdgeInsets.all(16.0),
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            classLink.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: classLink.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          classLink.comment,
        ),
      ),
      Visibility(
        visible: classLink.isAcquired,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
      ),
      Visibility(
        visible: classLink.isAcquired,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(
            context,
            classLink.link,
          ),
        ),
      ),
      const SizedBox(height: 8.0),
      Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<ClassLinkRepository>()
                      .setArchive(classLink.id, !classLink.isArchived);
                  Navigator.of(context).pop();
                },
                child: Icon(classLink.isArchived
                    ? Icons.unarchive_rounded
                    : Icons.archive_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () async => context
                    .read<ApiRepository>()
                    .fetchDetailClassLink(classLink),
                child: const Icon(Icons.sync_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => Share.share(
                    '${classLink.comment}\n\n${classLink.link}',
                    subject: classLink.title),
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
