import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/class_link.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/views/common/widget.dart';
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
      builder: (_, AsyncSnapshot<List<ClassLink>> snapshot) {
        if (snapshot.hasData) {
          _classLinks = snapshot.data!;
          _classLinks.sort(((a, b) => b.compareTo(a)));
          var filteredClassLinks = _classLinks
              .where((e) => _filterStatus ? !e.isArchived : true)
              .toList();
          return Scaffold(
            floatingActionButton: buildFloatingActionButton(
              onPressed: context.read<ApiRepository>().fetchClassLinks,
              iconData: KIcons.update,
            ),
            body: NestedScrollView(
              headerSliverBuilder: (_, __) => [_buildAppBar()],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchClassLinks(),
                child: filteredClassLinks.isEmpty
                    ? buildCenterItemLayoutBuilder(
                        KIcons.classLink, '授業リンクはありません')
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _searchStatus
                            ? _suggestClassLinks.length
                            : _classLinks.length,
                        itemBuilder: (_, index) => _searchStatus
                            ? _buildCard(_suggestClassLinks[index])
                            : _buildCard(_classLinks[index]),
                      ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildAppBar() {
    return Builder(builder: (context) {
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
                    icon: Icon(KIcons.close),
                  ),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: (() =>
                        setState(() => _filterStatus = !_filterStatus)),
                    icon: Icon(
                        _filterStatus ? KIcons.filterOn : KIcons.filterOff),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: (() => setState(() {
                          _searchStatus = true;
                          _suggestClassLinks = [];
                        })),
                    icon: Icon(KIcons.search),
                  ),
                ),
              ],
        bottom: buildAppBarBottom(),
      );
    });
  }

  Widget _buildCard(ClassLink classLink) {
    return Builder(builder: (context) {
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: classLink.isArchived ? KIcons.unarchive : KIcons.archive,
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: KIcons.update,
              label: '更新',
            ),
          ],
        ),
        child: ListTile(
          onTap: () async {
            if (classLink.isAcquired) {
              showModalOnTap(context, buildClassLinkModal(classLink));
            } else {
              await showOkCancelAlertDialog(
                        context: context,
                        title: '取得しますか？',
                        message: '未取得の授業リンクです。取得するためにはログイン状態である必要があります。',
                        okLabel: '取得',
                        cancelLabel: 'キャンセル',
                      ) ==
                      OkCancelResult.ok
                  ? context
                      .read<ApiRepository>()
                      .fetchDetailClassLink(classLink)
                  : showModalOnTap(context, buildClassLinkModal(classLink));
            }
          },
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      classLink.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Visibility(
                    visible: classLink.isArchived,
                    child: Icon(KIcons.archive),
                  )
                ],
              ),
            ],
          ),
          subtitle: Text(
            classLink.subject,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    });
  }
}

Widget buildClassLinkModal(ClassLink classLink) {
  return Builder(builder: (context) {
    return ListView(
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
                child: Icon(KIcons.archive),
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(classLink.comment),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(classLink.link),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<ClassLinkRepository>()
                        .setArchive(classLink.id, !classLink.isArchived);
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                      classLink.isArchived ? KIcons.unarchive : KIcons.archive),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async => context
                      .read<ApiRepository>()
                      .fetchDetailClassLink(classLink),
                  child: Icon(KIcons.update),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () => Share.share(
                      '${classLink.comment}\n\n${classLink.link}',
                      subject: classLink.title),
                  child: Icon(KIcons.share),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  });
}
