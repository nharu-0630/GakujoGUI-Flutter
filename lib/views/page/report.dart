import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/views/common/widget.dart';
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
      builder: (_, AsyncSnapshot<List<Report>> snapshot) {
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
            floatingActionButton: buildFloatingActionButton(
              onPressed: context.read<ApiRepository>().fetchReports,
              iconData: KIcons.update,
            ),
            body: NestedScrollView(
              headerSliverBuilder: (_, __) => [_buildAppBar()],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchReports(),
                child: filteredReports.isEmpty
                    ? buildCenterItemLayoutBuilder(KIcons.report, 'レポートはありません')
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8.0),
                        itemCount: _searchStatus
                            ? _suggestReports.length
                            : filteredReports.length,
                        itemBuilder: (_, index) => _searchStatus
                            ? _buildCard(_suggestReports[index])
                            : _buildCard(filteredReports[index]),
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
                    icon: Icon(
                        _filterStatus ? KIcons.filterOn : KIcons.filterOff),
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
        bottom: buildAppBarBottom(),
      ),
    );
  }

  Widget _buildCard(Report report) {
    return Builder(
      builder: (context) => Slidable(
        key: Key(report.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => context
                  .read<ReportRepository>()
                  .setArchive(report.id, !report.isArchived)
                  .then((value) => setState(() {})),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: KIcons.update,
              label: '更新',
            ),
          ],
        ),
        child: ListTile(
          onTap: () async {
            if (report.isAcquired) {
              showModalOnTap(context, buildReportModal(report));
            } else {
              await showFetchConfirmDialog(
                        context: context,
                        value: 'レポート',
                      ) ==
                      OkCancelResult.ok
                  ? context.read<ApiRepository>().fetchDetailReport(report)
                  : showModalOnTap(context, buildReportModal(report));
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
                  report.title,
                  style: Theme.of(context).textTheme.titleMedium,
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
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.subject,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                report.endDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: (() {
                    if (!report.isSubmitted &&
                        report.endDateTime.isBefore(
                            DateTime.now().add(const Duration(days: 1)))) {
                      return Theme.of(context).colorScheme.error;
                    }
                    return Theme.of(context).textTheme.bodySmall!.color;
                  })(),
                  fontWeight: (() {
                    if (!report.isSubmitted &&
                        report.endDateTime.isBefore(
                            DateTime.now().add(const Duration(days: 1)))) {
                      return FontWeight.bold;
                    }
                    return FontWeight.normal;
                  })(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildReportModal(Report report) {
  return Builder(
    builder: (context) => ListView(
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
                report.startDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '-',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                report.endDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildRadiusBadge(report.status),
              buildRadiusBadge(report.isSubmitted
                  ? '提出済 ${report.submittedDateTime.toLocal().toDateTimeString()}'
                  : '未提出'),
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
          child:
              buildAutoLinkText(report.isAcquired ? report.description : '未取得'),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(report.isAcquired ? report.message : '未取得'),
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
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<ReportRepository>()
                        .setArchive(report.id, !report.isArchived);
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                      report.isArchived ? KIcons.unarchive : KIcons.archive),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async =>
                      context.read<ApiRepository>().fetchDetailReport(report),
                  child: Icon(KIcons.update),
                ),
              ),
            ),
            Expanded(
              child: Padding(
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
    ),
  );
}
