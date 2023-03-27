import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/timetable.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late List<Report> _reports;
  late List<Quiz> _quizzes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          FutureBuilder(
            future: Future.wait([
              context.watch<TimetableRepository>().getAll(),
              context.watch<ReportRepository>().getAll(),
              context.watch<QuizRepository>().getAll()
            ]),
            builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                var timetables = snapshot.data![0] as List<Timetable>;
                _reports = (snapshot.data![1] as List<Report>)
                    .where((e) => !(e.isArchived ||
                        !(!e.isSubmitted &&
                            e.endDateTime.isAfter(DateTime.now()))))
                    .toList();
                _quizzes = (snapshot.data![2] as List<Quiz>)
                    .where((e) => !(e.isArchived ||
                        !(!e.isSubmitted &&
                            e.endDateTime.isAfter(DateTime.now()))))
                    .toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(1.0),
                      2: FlexColumnWidth(1.0),
                      3: FlexColumnWidth(1.0),
                      4: FlexColumnWidth(1.0),
                      5: FlexColumnWidth(1.0),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          const TableCell(child: SizedBox()),
                          for (var i = 0; i < 5; i++)
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '月火水木金'[i],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      for (var i = 0; i < 5; i++)
                        TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${i + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            for (var j = 0; j < 5; j++)
                              timetables.any(
                                      (e) => e.weekday == j && e.period == i)
                                  ? _buildCell(timetables.firstWhere(
                                      (e) => e.weekday == j && e.period == i))
                                  : const TableCell(child: SizedBox()),
                          ],
                        ),
                    ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildCell(Timetable timetable) {
    return Builder(builder: (context) {
      return badges.Badge(
        showBadge: (_reports
                    .where((e) => e.subject == timetable.subject)
                    .length +
                _quizzes.where((e) => e.subject == timetable.subject).length) >
            0,
        ignorePointer: true,
        badgeContent: Text(
          (_reports.where((e) => e.subject == timetable.subject).length +
                  _quizzes.where((e) => e.subject == timetable.subject).length)
              .toString(),
        ),
        position: badges.BadgePosition.topEnd(top: 0, end: 0),
        child: TableCell(
          child: SizedBox(
            height: max(MediaQuery.of(context).size.height * .8 / 5, 120.0),
            width: double.infinity,
            child: Card(
              color: Color.lerp(timetable.subject.toColor(),
                  Theme.of(context).cardColor, 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () =>
                    showModalOnTap(context, buildTimetableModal(timetable)),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        timetable.subject,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                      ),
                      Flexible(
                        child: Text(
                          timetable.className,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          timetable.classRoom,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          timetable.teacher,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

Widget buildTimetableModal(Timetable timetable) {
  return Builder(builder: (context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            timetable.subject,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          direction: Axis.horizontal,
          children: [
            buildIconItem(LineIcons.shapes, timetable.className),
            buildIconItem(LineIcons.mapPin, timetable.classRoom),
            buildIconItem(LineIcons.userGraduate, timetable.teacher),
          ],
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          direction: Axis.horizontal,
          spacing: 32.0,
          runSpacing: 8.0,
          children: [
            buildShortItem('担当教員名', timetable.syllabusTeacher),
            buildShortItem('所属等', timetable.syllabusAffiliation),
            buildShortItem('研究室', timetable.syllabusResearchRoom),
            buildShortItem('分担教員名', timetable.syllabusSharingTeacher),
            buildShortItem('クラス', timetable.syllabusClassName),
            buildShortItem('学期', timetable.syllabusSemesterName),
            buildShortItem('必修選択区分', timetable.syllabusSelectionSection),
            buildShortItem('対象学年', timetable.syllabusTargetGrade),
            buildShortItem('単位数', timetable.syllabusCredit),
            buildShortItem('曜日・時限', timetable.syllabusWeekdayPeriod),
            buildShortItem('教室', timetable.syllabusClassRoom),
          ],
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        ...buildLongItem('キーワード', timetable.syllabusKeyword),
        ...buildLongItem('授業の目標', timetable.syllabusClassTarget),
        ...buildLongItem('学習内容', timetable.syllabusLearningDetail),
        ...buildLongItem('授業計画', timetable.syllabusClassPlan),
        ...buildLongItem('テキスト', timetable.syllabusTextbook),
        ...buildLongItem('参考書', timetable.syllabusReferenceBook),
        ...buildLongItem('予習・復習について', timetable.syllabusPreparationReview),
        ...buildLongItem('成績評価の方法･基準', timetable.syllabusEvaluationMethod),
        ...buildLongItem('オフィスアワー', timetable.syllabusOfficeHour),
        ...buildLongItem('担当教員からのメッセージ', timetable.syllabusMessage),
        ...buildLongItem('アクティブ・ラーニング', timetable.syllabusActiveLearning),
        ...buildLongItem(
            '実務経験のある教員の有無', timetable.syllabusTeacherPracticalExperience),
        ...buildLongItem(
            '実務経験のある教員の経歴と授業内容', timetable.syllabusTeacherCareerClassDetail),
        ...buildLongItem('教職科目区分', timetable.syllabusTeachingProfessionSection),
        ...buildLongItem('関連授業科目', timetable.syllabusRelatedClassSubjects),
        ...buildLongItem('その他', timetable.syllabusOther),
        ...buildLongItem('在宅授業形態', timetable.syllabusHomeClassStyle),
        ...buildLongItem('在宅授業形態（詳細）', timetable.syllabusHomeClassStyleDetail),
      ],
    );
  });
}
