import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/views/page/quiz.dart';
import 'package:gakujo_gui/views/page/report.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.watch<ReportRepository>().getAll(),
        context.watch<QuizRepository>().getAll()
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          var reports = snapshot.data![0] as List<Report>;
          var quizzes = snapshot.data![1] as List<Quiz>;
          reports = reports
              .where((e) => !(e.isArchived ||
                  !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now()))))
              .toList();
          quizzes = quizzes
              .where((e) => !(e.isArchived ||
                  !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now()))))
              .toList();
          List<dynamic> tasks = [...reports, ...quizzes];
          tasks.sort((a, b) => b.endDateTime.compareTo(a.endDateTime));
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            KIcons.task,
                            size: 32.0,
                          ),
                        ),
                        Text(
                          'タスクはありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: ((context, index) => tasks[index] is Report
                        ? _buildReportTile(context, tasks[index] as Report)
                        : _buildQuizCard(context, tasks[index] as Quiz)),
                  ),
          );
        } else {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ));
        }
      },
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz) {
    return ListTile(
      onTap: () async {
        if (quiz.isAcquired) {
          MediaQuery.of(context).orientation == Orientation.portrait
              ? showModalBottomSheet(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  isScrollControlled: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(0.0))),
                  context: context,
                  builder: (context) => buildQuizModal(context, quiz),
                )
              : SideSheet.right(
                  sheetColor: Theme.of(context).colorScheme.surface,
                  body: SizedBox(
                    width: MediaQuery.of(context).size.width * .6,
                    child: buildQuizModal(context, quiz),
                  ),
                  context: context,
                );
        } else {
          await showOkCancelAlertDialog(
                    context: context,
                    title: '未取得の小テストです。',
                    message: '取得しますか？',
                    okLabel: '取得',
                    cancelLabel: 'キャンセル',
                  ) ==
                  OkCancelResult.ok
              ? context.read<ApiRepository>().fetchDetailQuiz(quiz)
              : null;
        }
      },
      leading: Icon(KIcons.quiz),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              quiz.subject,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            quiz.endDateTime.toLocal().toDetailString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              quiz.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Visibility(
            visible: quiz.fileNames?.isNotEmpty ?? false,
            child: Text(
              '${quiz.fileNames?.length ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Visibility(
            visible: quiz.fileNames?.isNotEmpty ?? false,
            child: Icon(KIcons.attachment),
          ),
          Visibility(
            visible: quiz.isArchived,
            child: Icon(KIcons.archive),
          )
        ],
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, Report report) {
    return ListTile(
      onTap: () async {
        if (report.isAcquired) {
          MediaQuery.of(context).orientation == Orientation.portrait
              ? showModalBottomSheet(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  isScrollControlled: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(0.0))),
                  context: context,
                  builder: (context) => buildReportModal(context, report),
                )
              : SideSheet.right(
                  sheetColor: Theme.of(context).colorScheme.surface,
                  body: SizedBox(
                    width: MediaQuery.of(context).size.width * .6,
                    child: buildReportModal(context, report),
                  ),
                  context: context,
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
      leading: Icon(KIcons.report),
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
            report.endDateTime.toLocal().toDetailString(),
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
    );
  }
}
