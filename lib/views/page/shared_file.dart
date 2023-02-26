import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/shared_file.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:provider/provider.dart';

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
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.folder_shared_rounded,
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                        _suggestSharedFiles = [];
                      })),
                  icon: const Icon(Icons.search_rounded),
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
            icon: sharedFile.isArchived
                ? Icons.unarchive_rounded
                : Icons.archive_rounded,
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
            icon: Icons.sync_rounded,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          if (!sharedFile.isAcquired) {
            showDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                content: const Text('未取得の授業共有ファイルです。取得しますか？'),
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
                      context
                          .read<ApiRepository>()
                          .fetchDetailSharedFile(sharedFile);
                    },
                  )
                ],
              ),
            );
          } else {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              context: context,
              builder: (context) => DraggableScrollableSheet(
                expand: false,
                builder: (context, controller) {
                  return buildSharedFileModal(context, sharedFile, controller);
                },
              ),
            );
          }
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                sharedFile.subject,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              sharedFile.publicPeriod,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        subtitle: Row(
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
              child: const Icon(Icons.file_present_rounded),
            ),
            Visibility(
              visible: sharedFile.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
    );
  }
}
