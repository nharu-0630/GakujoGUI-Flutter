import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/questionnaire.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:gakujo_gui/views/page/questionnaire.dart';
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
        context.watch<QuizRepository>().getSubmittable(),
        context.watch<QuestionnaireRepository>().getSubmittable(),
      ]),
      builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          var reports = snapshot.data![0] as List<Report>;
          var quizzes = snapshot.data![1] as List<Quiz>;
          var questionnaires = snapshot.data![2] as List<Questionnaire>;
          List<dynamic> tasks = [...reports, ...quizzes, ...questionnaires];
          tasks.sort((a, b) => b.endDateTime.compareTo(a.endDateTime));
          return tasks.isEmpty
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
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: ((_, index) => _buildCard(tasks[index])),
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

  Widget _buildCard(dynamic task) {
    switch (task.runtimeType) {
      case Report:
        return _buildReportCard(task as Report);
      case Quiz:
        return _buildQuizCard(task as Quiz);
      case Questionnaire:
        return _buildQuestionnaireCard(task as Questionnaire);
      default:
        return Container();
    }
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Builder(
      builder: (context) => Card(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          onTap: () async {
            if (quiz.isAcquired) {
              showModalOnTap(context, buildQuizModal(quiz));
            } else {
              await showFetchConfirmDialog(
                        context: context,
                        value: '小テスト',
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
                quiz.endDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Builder(
      builder: (context) => Card(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
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
                report.endDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionnaireCard(Questionnaire questionnaire) {
    return Builder(
      builder: (context) => Card(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          onTap: () async {
            if (questionnaire.isAcquired) {
              showModalOnTap(context, buildQuestionnaireModal(questionnaire));
            } else {
              await showFetchConfirmDialog(
                        context: context,
                        value: '授業アンケート',
                      ) ==
                      OkCancelResult.ok
                  ? context
                      .read<ApiRepository>()
                      .fetchDetailQuestionnaire(questionnaire)
                  : showModalOnTap(
                      context, buildQuestionnaireModal(questionnaire));
            }
          },
          leading: Icon(KIcons.report),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  questionnaire.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Visibility(
                visible: questionnaire.fileNames?.isNotEmpty ?? false,
                child: Text(
                  '${questionnaire.fileNames?.length ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Visibility(
                visible: questionnaire.fileNames?.isNotEmpty ?? false,
                child: Icon(KIcons.attachment),
              ),
              Visibility(
                visible: questionnaire.isArchived,
                child: Icon(KIcons.archive),
              )
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  questionnaire.subject,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                questionnaire.endDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
