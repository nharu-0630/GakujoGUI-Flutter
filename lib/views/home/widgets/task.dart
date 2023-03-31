import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:gakujo_gui/views/page/quiz.dart';
import 'package:gakujo_gui/views/page/report.dart';
import 'package:provider/provider.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.watch<ReportRepository>().getSubmittable(),
        context.watch<QuizRepository>().getSubmittable()
      ]),
      builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          var reports = snapshot.data![0] as List<Report>;
          var quizzes = snapshot.data![1] as List<Quiz>;
          List<dynamic> tasks = [...reports, ...quizzes];
          tasks.sort((a, b) => b.endDateTime.compareTo(a.endDateTime));
          return Padding(
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
                    itemBuilder: ((_, index) => tasks[index] is Report
                        ? _buildReportCard(tasks[index] as Report)
                        : _buildQuizCard(tasks[index] as Quiz)),
                  ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Builder(builder: (context) {
      return Card(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          onTap: () async {
            if (quiz.isAcquired) {
              showModalOnTap(context, buildQuizModal(quiz));
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
                  : showModalOnTap(context, buildQuizModal(quiz));
            }
          },
          leading: Icon(KIcons.quiz),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: Theme.of(context).textTheme.titleMedium,
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
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz.subject,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                quiz.endDateTime.toLocal().toDetailString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildReportCard(Report report) {
    return Builder(builder: (context) {
      return Card(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          onTap: () async {
            if (report.isAcquired) {
              showModalOnTap(context, buildReportModal(report));
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
                  : showModalOnTap(context, buildReportModal(report));
            }
          },
          leading: Icon(KIcons.report),
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
                report.endDateTime.toLocal().toDetailString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    });
  }
}
