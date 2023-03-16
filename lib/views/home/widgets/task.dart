import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/KIcons.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/views/page/quiz.dart';
import 'package:gakujo_gui/views/page/report.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz) {
    return ListTile(
      onTap: () async {
        if (quiz.isAcquired) {
          showModalBottomSheet(
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16.0))),
            context: context,
            builder: (context) => DraggableScrollableSheet(
              expand: false,
              builder: (context, controller) {
                return buildQuizModal(context, quiz, controller);
              },
            ),
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
            DateFormat('yyyy/MM/dd HH:mm', 'ja')
                .format(quiz.endDateTime.toLocal()),
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
    );
  }
}
