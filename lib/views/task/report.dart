import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/provide.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    final List<Report> reports = context
        .watch<ApiProvider>()
        .api
        .reports
        .where((e) => _filterStatus
            ? !(e.isArchived ||
                !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now())))
            : true)
        .toList();
    reports.sort(((a, b) => b.compareTo(a)));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          reports.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.beach_access_rounded,
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
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: _searchStatus
                        ? SliverChildBuilderDelegate(
                            (_, index) =>
                                _buildCard(context, _suggestReports[index]),
                            childCount: _suggestReports.length,
                          )
                        : SliverChildBuilderDelegate(
                            (_, index) => _buildCard(context, reports[index]),
                            childCount: reports.length,
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
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      title: _searchStatus
          ? TextField(
              onChanged: (value) {
                setState(() {
                  _suggestReports = context
                      .read<ApiProvider>()
                      .api
                      .reports
                      .where((e) =>
                          e.title.contains(value) || e.subject.contains(value))
                      .toList();
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
                icon: const Icon(Icons.close),
              ),
            ]
          : [
              IconButton(
                onPressed: (() {
                  setState(() {
                    _filterStatus = !_filterStatus;
                  });
                }),
                icon: Icon(
                    _filterStatus ? Icons.filter_alt : Icons.filter_alt_off),
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
                  icon: const Icon(Icons.search),
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
            icon: report.isArchived ? Icons.unarchive : Icons.archive,
            label: report.isArchived ? 'アーカイブ解除' : 'アーカイブ',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: ((context) {}),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.sync,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () => showModalBottomSheet(
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
          context: context,
          builder: (context) => _buildModal(report),
        ),
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
              ),
            ),
            Visibility(
              visible: report.isArchived,
              child: const Icon(Icons.archive_outlined),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModal(Report report) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top,
      child: Column(
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
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.archive_outlined),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              report.isAcquired ? report.description : '未取得',
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Divider(thickness: 2.0),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              report.isAcquired ? report.message : '未取得',
            ),
          ),
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  context
                      .read<ApiProvider>()
                      .setArchiveReport(report.id, !report.isArchived);
                  Navigator.of(context).pop();
                },
                child:
                    Icon(report.isArchived ? Icons.unarchive : Icons.archive),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close_rounded),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.sync_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
