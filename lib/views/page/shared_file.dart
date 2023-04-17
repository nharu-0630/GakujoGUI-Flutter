import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SharedFilePage extends StatefulWidget {
  const SharedFilePage({Key? key}) : super(key: key);

  @override
  State<SharedFilePage> createState() => _SharedFilePageState();
}

class _SharedFilePageState extends State<SharedFilePage> {
  bool _searchStatus = false;
  bool _filterStatus = false;
  List<SharedFile> _sharedFiles = [];
  List<SharedFile> _suggestSharedFiles = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<SharedFileRepository>().getAll(),
      builder: (_, AsyncSnapshot<List<SharedFile>> snapshot) {
        if (snapshot.hasData) {
          _sharedFiles = snapshot.data!;
          _sharedFiles.sort(((a, b) => b.compareTo(a)));
          var filteredSharedFiles = _sharedFiles
              .where((e) => _filterStatus ? !e.isArchived : true)
              .toList();
          return Scaffold(
            floatingActionButton: buildFloatingActionButton(
              onPressed: context.read<ApiRepository>().fetchSharedFiles,
              iconData: KIcons.update,
            ),
            body: NestedScrollView(
              headerSliverBuilder: (_, __) => [_buildAppBar()],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchSharedFiles(),
                child: filteredSharedFiles.isEmpty
                    ? buildCenterItemLayoutBuilder(
                        KIcons.sharedFile, '授業共有ファイルはありません')
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8.0),
                        itemCount: _searchStatus
                            ? _suggestSharedFiles.length
                            : _sharedFiles.length,
                        itemBuilder: (_, index) => _searchStatus
                            ? _buildCard(_suggestSharedFiles[index])
                            : _buildCard(_sharedFiles[index]),
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
    return Builder(
      builder: (context) => SliverAppBar(
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
                onChanged: (value) => setState(() => _suggestSharedFiles =
                    _sharedFiles.where((e) => e.contains(value)).toList()),
                autofocus: true,
                textInputAction: TextInputAction.search,
              )
            : const Text('授業共有ファイル'),
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
                          _suggestSharedFiles = [];
                        })),
                    icon: Icon(KIcons.search),
                  ),
                ),
              ],
        bottom: buildAppBarBottom(),
      ),
    );
  }

  Widget _buildCard(SharedFile sharedFile) {
    return Builder(
      builder: (context) => Slidable(
        key: Key(sharedFile.hashCode.toString()),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => context
                  .read<SharedFileRepository>()
                  .setArchive(
                      sharedFile.hashCode.toString(), !sharedFile.isArchived)
                  .then((value) => setState(() {})),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: sharedFile.isArchived ? KIcons.unarchive : KIcons.archive,
              label: sharedFile.isArchived ? 'アーカイブ解除' : 'アーカイブ',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async => context
                  .read<ApiRepository>()
                  .fetchDetailSharedFile(sharedFile),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: KIcons.update,
              label: '更新',
            ),
          ],
        ),
        child: ListTile(
          onTap: () async {
            if (sharedFile.isAcquired) {
              showModalOnTap(context, buildSharedFileModal(sharedFile));
            } else {
              await showFetchConfirmDialog(
                        context: context,
                        value: '授業共有ファイル',
                      ) ==
                      OkCancelResult.ok
                  ? context
                      .read<ApiRepository>()
                      .fetchDetailSharedFile(sharedFile)
                  : showModalOnTap(context, buildSharedFileModal(sharedFile));
            }
          },
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sharedFile.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Visibility(
                    visible: sharedFile.fileNames?.isNotEmpty ?? false,
                    child: Text(
                      '${sharedFile.fileNames?.length ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Visibility(
                    visible: sharedFile.fileNames?.isNotEmpty ?? false,
                    child: Icon(KIcons.attachment),
                  ),
                  Visibility(
                    visible: sharedFile.isArchived,
                    child: Icon(KIcons.archive),
                  )
                ],
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  sharedFile.subject,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                sharedFile.updateDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSharedFileModal(SharedFile sharedFile) {
  return Builder(
    builder: (context) => ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              sharedFile.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              sharedFile.publicPeriod != '～'
                  ? sharedFile.publicPeriod.isNotEmpty
                      ? sharedFile.publicPeriod
                      : '未取得'
                  : '無期限',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildRadiusBadge(sharedFile.fileSize),
              Visibility(
                visible: sharedFile.isArchived,
                child: Icon(KIcons.archive),
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(
              sharedFile.isAcquired ? sharedFile.description : '未取得'),
        ),
        Visibility(
          visible: sharedFile.fileNames?.isNotEmpty ?? false,
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Divider(thickness: 2.0),
          ),
        ),
        Visibility(
          visible: sharedFile.fileNames?.isNotEmpty ?? false,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: buildFileList(sharedFile.fileNames),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SharedFileRepository>().setArchive(
                        sharedFile.hashCode.toString(), !sharedFile.isArchived);
                    Navigator.of(context).pop();
                  },
                  child: Icon(sharedFile.isArchived
                      ? KIcons.unarchive
                      : KIcons.archive),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async => context
                      .read<ApiRepository>()
                      .fetchDetailSharedFile(sharedFile),
                  child: Icon(KIcons.update),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () => Share.share(sharedFile.description,
                      subject: sharedFile.title),
                  child: Icon(KIcons.share),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    ),
  );
}
