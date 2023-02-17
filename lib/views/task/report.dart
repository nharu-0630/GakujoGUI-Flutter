import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _searchStatus = false;
  bool _filterStatus = false;
  List<Report> _suggestReports = [];

  @override
  Widget build(BuildContext context) {
    // var reports = context
    //     .watch<ApiProvider>()
    //     .reports
    //     .where((e) => _filterStatus
    //         ? !(e.isArchived ||
    //             !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now())))
    //         : true)
    //     .toList();
    var reports = [];
    reports.sort(((a, b) => b.compareTo(a)));
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) =>
            [_buildAppBar(context)],
        body: RefreshIndicator(
          onRefresh: () async => context.read<ApiProvider>().fetchReports(),
          child: reports.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.task_rounded,
                                size: 48.0,
                              ),
                            ),
                            Text(
                              'タスクはありません',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount:
                      _searchStatus ? _suggestReports.length : reports.length,
                  itemBuilder: (context, index) => _searchStatus
                      ? _buildCard(context, _suggestReports[index])
                      : _buildCard(context, reports[index]),
                ),
        ),
      ),
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
                setState(() {
                  // _suggestReports = context
                  //     .read<ApiProvider>()
                  //     .reports
                  //     .where((e) => e.contains(value))
                  //     .toList();
                });
              },
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : const Text('レポート'),
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
                    _filterStatus = !_filterStatus;
                  });
                }),
                icon: Icon(_filterStatus
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_off_rounded),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: (() {
                    setState(() {
                      _searchStatus = true;
                      _suggestReports = [];
                    });
                  }),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCard(BuildContext context, Report report) {
    return Slidable(
      key: Key(report.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: ((context) {
              context
                  .read<ApiProvider>()
                  .setArchiveReport(report.id, !report.isArchived);
            }),
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: report.isArchived
                ? Icons.unarchive_rounded
                : Icons.archive_rounded,
            label: report.isArchived ? 'アーカイブ解除' : 'アーカイブ',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async =>
                context.read<ApiProvider>().fetchDetailReport(report),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.sync_rounded,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (!report.isAcquired) {
            await showDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                content: const Text('未取得のレポートです。取得しますか？'),
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
                      context.read<ApiProvider>().fetchDetailReport(report);
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
                return _buildModal(report, controller);
              },
            ),
          );
        },
        leading: Icon(
          (() {
            if (report.isSubmitted) {
              if (report.endDateTime.isAfter(DateTime.now())) {
                return Icons.check_box_outlined;
              } else {
                return Icons.check_box_rounded;
              }
            } else {
              if (report.endDateTime.isAfter(DateTime.now())) {
                return Icons.crop_square_outlined;
              } else {
                return Icons.square_rounded;
              }
            }
          })(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                report.subject,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(report.endDateTime.toLocal()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                report.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Visibility(
              visible: report.fileNames?.isNotEmpty ?? false,
              child: const Icon(Icons.file_present_rounded),
            ),
            Visibility(
              visible: report.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModal(Report report, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              report.title,
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
                    .format(report.startDateTime.toLocal()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Icon(Icons.arrow_right_alt_rounded),
              Text(
                DateFormat('yyyy/MM/dd HH:mm', 'ja')
                    .format(report.endDateTime.toLocal()),
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
                  report.status,
                  style: Theme.of(context).textTheme.bodyLarge,
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
                  report.isSubmitted
                      ? '提出済 ${DateFormat('yyyy/MM/dd HH:mm', 'ja').format(report.submittedDateTime.toLocal())}'
                      : '未提出',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Visibility(
                visible: report.isArchived,
                child: const Icon(Icons.archive_rounded),
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SelectableText(
            report.isAcquired ? report.description : '未取得',
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SelectableText(
            report.isAcquired ? report.message : '未取得',
          ),
        ),
        Visibility(
          visible: report.fileNames?.isNotEmpty ?? false,
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Divider(thickness: 2.0),
          ),
        ),
        Visibility(
          visible: report.fileNames?.isNotEmpty ?? false,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: buildFileList(report.fileNames),
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
                        .read<ApiProvider>()
                        .setArchiveReport(report.id, !report.isArchived);
                    Navigator.of(context).pop();
                  },
                  child: Icon(report.isArchived
                      ? Icons.unarchive_rounded
                      : Icons.archive_rounded),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async =>
                      context.read<ApiProvider>().fetchDetailReport(report),
                  child: const Icon(Icons.sync_rounded),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () => Share.share(
                      '${report.description}\n\n${report.message}',
                      subject: report.title),
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
