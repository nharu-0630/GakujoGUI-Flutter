import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
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
  List<Report> _reports = [];
  List<Report> _suggestReports = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<ReportRepository>().getAll(),
      builder: (context, AsyncSnapshot<List<Report>> snapshot) {
        if (snapshot.hasData) {
          _reports = snapshot.data!;
          _reports.sort(((a, b) => b.compareTo(a)));
          var filteredReports = _reports
              .where((e) => _filterStatus
                  ? !(e.isArchived ||
                      !(!e.isSubmitted &&
                          e.endDateTime.isAfter(DateTime.now())))
                  : true)
              .toList();
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) =>
                  [_buildAppBar(context)],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchReports(),
                child: filteredReports.isEmpty
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
                                      KIcons.report,
                                      size: 48.0,
                                    ),
                                  ),
                                  Text(
                                    'レポートはありません',
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
                            ? _suggestReports.length
                            : filteredReports.length,
                        itemBuilder: (context, index) => _searchStatus
                            ? _buildCard(context, _suggestReports[index])
                            : _buildCard(context, filteredReports[index]),
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
              onChanged: (value) => setState(() => _suggestReports =
                  _reports.where((e) => e.contains(value)).toList()),
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : const Text('レポート'),
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
                        _suggestReports = [];
                      })),
                  icon: Icon(KIcons.search),
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
            onPressed: (context) => context
                .read<ReportRepository>()
                .setArchive(report.id, !report.isArchived)
                .then((value) => setState(() {})),
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: report.isArchived ? KIcons.unarchive : KIcons.archive,
            label: report.isArchived ? 'アーカイブ解除' : 'アーカイブ',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async =>
                context.read<ApiRepository>().fetchDetailReport(report),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: KIcons.sync,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (report.isAcquired) {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              context: context,
              builder: (context) => DraggableScrollableSheet(
                expand: false,
                builder: (context, controller) {
                  return buildReportModal(context, report, controller);
                },
              ),
            );
          } else {
            await showOkCancelAlertDialog(
                      context: context,
                      title: '未取得のレポートです。',
                      message: '取得しますか？',
                      okLabel: '取得',
                      cancelLabel: 'キャンセル',
                    ) ==
                    OkCancelResult.ok
                ? context.read<ApiRepository>().fetchDetailReport(report)
                : null;
          }
        },
        leading: Icon(
          (() {
            if (report.isSubmitted) {
              if (report.endDateTime.isAfter(DateTime.now())) {
                return KIcons.checkedAfter;
              } else {
                return KIcons.checkedBefore;
              }
            } else {
              if (report.endDateTime.isAfter(DateTime.now())) {
                return KIcons.uncheckedAfter;
              } else {
                return KIcons.uncheckedBefore;
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
              child: Text(
                '${report.fileNames?.length ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Visibility(
              visible: report.fileNames?.isNotEmpty ?? false,
              child: Icon(KIcons.attachment),
            ),
            Visibility(
              visible: report.isArchived,
              child: Icon(KIcons.archive),
            )
          ],
        ),
      ),
    );
  }
}

Widget buildReportModal(
    BuildContext context, Report report, ScrollController controller) {
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
            const Icon(LineIcons.arrowRight),
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
          report.isAcquired ? report.description : '未取得',
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
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
                      .read<ReportRepository>()
                      .setArchive(report.id, !report.isArchived);
                  Navigator.of(context).pop();
                },
                child:
                    Icon(report.isArchived ? KIcons.unarchive : KIcons.archive),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () async =>
                    context.read<ApiRepository>().fetchDetailReport(report),
                child: Icon(KIcons.sync),
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
