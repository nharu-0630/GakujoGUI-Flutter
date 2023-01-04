import 'package:flutter/material.dart';
import 'package:gakujo_task/constants/colors.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/task/quiz.dart';
import 'package:gakujo_task/views/task/report.dart';
import 'package:provider/provider.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      crossAxisCount: 2,
      children: [
        _buildReportTile(context),
        _buildQuizTile(context),
      ],
    );
  }

  Widget _buildReportTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const ReportPage()));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(
                Icons.text_snippet_rounded,
                color: kYellowDark,
                size: 36.0,
              ),
              Text(
                'レポート',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _buildStatus(
                  context,
                  kYellowDark.withOpacity(0.4),
                  '残り ${context.watch<ApiProvider>().api.reports.where((e) => !(e.isArchived || !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now())))).length}',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const QuizPage()));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(
                Icons.quiz_rounded,
                color: kRedDark,
                size: 36.0,
              ),
              Text(
                '小テスト',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _buildStatus(
                  context,
                  kRedDark.withOpacity(0.4),
                  '残り ${context.watch<ApiProvider>().api.quizzes.where((e) => !(e.isArchived || !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now())))).length}',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
