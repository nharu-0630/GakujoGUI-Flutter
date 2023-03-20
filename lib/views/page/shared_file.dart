import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:side_sheet/side_sheet.dart';

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
      builder: (context, AsyncSnapshot<List<SharedFile>> snapshot) {
        if (snapshot.hasData) {
          _sharedFiles = snapshot.data!;
          _sharedFiles.sort(((a, b) => b.compareTo(a)));
          var filteredSharedFiles = _sharedFiles
              .where((e) => _filterStatus ? !e.isArchived : true)
              .toList();
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) =>
                  [_buildAppBar(context)],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchSharedFiles(),
                child: filteredSharedFiles.isEmpty
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      KIcons.sharedFile,
                                      size: 48.0,
                                    ),
                                  ),
                                  Text(
                                    '授業共有ファイルはありません',
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
                            ? _suggestSharedFiles.length
                            : _sharedFiles.length,
                        itemBuilder: (context, index) => _searchStatus
                            ? _buildCard(context, _suggestSharedFiles[index])
                            : _buildCard(context, _sharedFiles[index]),
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
                  icon:
                      Icon(_filterStatus ? KIcons.filterOn : KIcons.filterOff),
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
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCard(BuildContext context, SharedFile sharedFile) {
    return Slidable(
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
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: sharedFile.isArchived ? KIcons.unarchive : KIcons.archive,
            label: sharedFile.isArchived ? 'アーカイブ解除' : 'アーカイブ',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async =>
                context.read<ApiRepository>().fetchDetailSharedFile(sharedFile),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: KIcons.update,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (sharedFile.isAcquired) {
            MediaQuery.of(context).orientation == Orientation.portrait
                ? showModalBottomSheet(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    isScrollControlled: false,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(0.0))),
                    context: context,
                    builder: (context) =>
                        buildSharedFileModal(context, sharedFile),
                  )
                : SideSheet.right(
                    sheetColor: Theme.of(context).colorScheme.surface,
                    body: SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      child: buildSharedFileModal(context, sharedFile),
                    ),
                    context: context,
                  );
          } else {
            await showOkCancelAlertDialog(
                      context: context,
                      title: '未取得の授業共有ファイルです。',
                      message: '取得しますか？',
                      okLabel: '取得',
                      cancelLabel: 'キャンセル',
                    ) ==
                    OkCancelResult.ok
                ? context
                    .read<ApiRepository>()
                    .fetchDetailSharedFile(sharedFile)
                : null;
          }
        },
        title: Row(
          children: [
            Expanded(
              child: Text(
                sharedFile.subject,
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
                    sharedFile.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

Widget buildSharedFileModal(BuildContext context, SharedFile sharedFile) {
  return ListView(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: sharedFile.publicPeriod.isNotEmpty,
              child: Container(
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
                  sharedFile.publicPeriod,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0),
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
                sharedFile.fileSize,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
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
          context,
          sharedFile.isAcquired ? sharedFile.description : '未取得',
        ),
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
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () {
                  context.read<SharedFileRepository>().setArchive(
                      sharedFile.hashCode.toString(), !sharedFile.isArchived);
                  Navigator.of(context).pop();
                },
                child: Icon(
                    sharedFile.isArchived ? KIcons.unarchive : KIcons.archive),
              ),
            ),
          ),
          Expanded(
            child: Container(
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
            child: Container(
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
  );
}
