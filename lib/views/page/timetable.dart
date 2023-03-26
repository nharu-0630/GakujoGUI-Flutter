import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/models/timetable.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          FutureBuilder(
              future: context.watch<TimetableRepository>().getAll(),
              builder: (context, AsyncSnapshot<List<Timetable>> snapshot) =>
                  snapshot.hasData
                      ? Padding(
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
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
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
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    for (var j = 0; j < 5; j++)
                                      snapshot.data!.any((e) =>
                                              e.weekday == j && e.period == i)
                                          ? _buildCell(
                                              context,
                                              snapshot.data!.firstWhere((e) =>
                                                  e.weekday == j &&
                                                  e.period == i))
                                          : const TableCell(child: SizedBox()),
                                  ],
                                ),
                            ],
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        )),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, Timetable timetable) {
    return TableCell(
      child: SizedBox(
        height: max(MediaQuery.of(context).size.height * .8 / 5, 120.0),
        child: Card(
          color: Color.lerp(
              timetable.subject.toColor(), Theme.of(context).cardColor, 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () async => MediaQuery.of(context).orientation ==
                    Orientation.portrait
                ? showModalBottomSheet(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    isScrollControlled: false,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.zero)),
                    context: context,
                    builder: (context) =>
                        buildTimetableModal(context, timetable),
                  )
                : SideSheet.right(
                    sheetColor: Theme.of(context).colorScheme.surface,
                    body: SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      child: buildTimetableModal(context, timetable),
                    ),
                    context: context,
                  ),
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
    );
  }
}

Widget _buildIconItem(BuildContext context, IconData icon, String text) =>
    Column(
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );

Widget _buildShortItem(BuildContext context, String title, String body) =>
    Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(body),
      ],
    );

List<Widget> _buildLongItem(BuildContext context, String title, String body) =>
    [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          body,
        ),
      ),
      const SizedBox(height: 8.0)
    ];

Widget buildTimetableModal(BuildContext context, Timetable timetable) {
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
          _buildIconItem(context, LineIcons.shapes, timetable.className),
          _buildIconItem(context, LineIcons.mapPin, timetable.classRoom),
          _buildIconItem(context, LineIcons.userGraduate, timetable.teacher),
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
          _buildShortItem(context, '担当教員名', timetable.syllabusTeacher),
          _buildShortItem(context, '所属等', timetable.syllabusAffiliation),
          _buildShortItem(context, '研究室', timetable.syllabusResearchRoom),
          _buildShortItem(context, '分担教員名', timetable.syllabusSharingTeacher),
          _buildShortItem(context, 'クラス', timetable.syllabusClassName),
          _buildShortItem(context, '学期', timetable.syllabusSemesterName),
          _buildShortItem(
              context, '必修選択区分', timetable.syllabusSelectionSection),
          _buildShortItem(context, '対象学年', timetable.syllabusTargetGrade),
          _buildShortItem(context, '単位数', timetable.syllabusCredit),
          _buildShortItem(context, '曜日・時限', timetable.syllabusWeekdayPeriod),
          _buildShortItem(context, '教室', timetable.syllabusClassRoom),
        ],
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      ..._buildLongItem(context, 'キーワード', timetable.syllabusKeyword),
      ..._buildLongItem(context, '授業の目標', timetable.syllabusClassTarget),
      ..._buildLongItem(context, '学習内容', timetable.syllabusLearningDetail),
      ..._buildLongItem(context, '授業計画', timetable.syllabusClassPlan),
      ..._buildLongItem(context, 'テキスト', timetable.syllabusTextbook),
      ..._buildLongItem(context, '参考書', timetable.syllabusReferenceBook),
      ..._buildLongItem(
          context, '予習・復習について', timetable.syllabusPreparationReview),
      ..._buildLongItem(
          context, '成績評価の方法･基準', timetable.syllabusEvaluationMethod),
      ..._buildLongItem(context, 'オフィスアワー', timetable.syllabusOfficeHour),
      ..._buildLongItem(context, '担当教員からのメッセージ', timetable.syllabusMessage),
      ..._buildLongItem(
          context, 'アクティブ・ラーニング', timetable.syllabusActiveLearning),
      ..._buildLongItem(context, '実務経験のある教員の有無',
          timetable.syllabusTeacherPracticalExperience),
      ..._buildLongItem(context, '実務経験のある教員の経歴と授業内容',
          timetable.syllabusTeacherCareerClassDetail),
      ..._buildLongItem(
          context, '教職科目区分', timetable.syllabusTeachingProfessionSection),
      ..._buildLongItem(
          context, '関連授業科目', timetable.syllabusRelatedClassSubjects),
      ..._buildLongItem(context, 'その他', timetable.syllabusOther),
      ..._buildLongItem(context, '在宅授業形態', timetable.syllabusHomeClassStyle),
      ..._buildLongItem(
          context, '在宅授業形態（詳細）', timetable.syllabusHomeClassStyleDetail),
    ],
  );
}
