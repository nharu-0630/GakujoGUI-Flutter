import 'dart:io';

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
              builder: (context, AsyncSnapshot<List<Timetable>> snapshot) {
                return snapshot.hasData
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
                                                  fontWeight: FontWeight.bold),
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
                      );
              }),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, Timetable timetable) {
    return TableCell(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .8 / 5,
        child: Card(
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
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(0.0))),
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
            child: ClipPath(
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0))),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                    color: timetable.subject.toColor(),
                    width: 6.0,
                  )),
                ),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return orientation == Orientation.portrait ||
                            Platform.isWindows ||
                            Platform.isLinux ||
                            Platform.isMacOS
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timetable.subject,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.visible,
                                ),
                                Flexible(
                                  child: Text(
                                    timetable.className,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    timetable.classRoom,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    timetable.teacher,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    timetable.subject,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(LineIcons.shapes),
            const SizedBox(width: 8.0),
            Text(
              timetable.className,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 16.0),
            const Icon(LineIcons.mapPin),
            const SizedBox(width: 8.0),
            Text(
              timetable.classRoom,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 16.0),
            const Icon(LineIcons.userGraduate),
            const SizedBox(width: 8.0),
            Text(
              timetable.teacher,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  '担当教員名',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusTeacher),
              ],
            ),
            const SizedBox(width: 16.0),
            Column(
              children: [
                Text(
                  '所属等',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusAffiliation),
              ],
            ),
            const SizedBox(width: 16.0),
            Column(
              children: [
                Text(
                  '研究室',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusResearchRoom),
              ],
            ),
            const SizedBox(width: 16.0),
            Column(
              children: [
                Text(
                  '分担教員名',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusSharingTeacher),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                'クラス',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusClassName),
            ],
          ),
          const SizedBox(width: 16.0),
          Column(
            children: [
              Text(
                '学期',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusSemesterName),
            ],
          ),
          const SizedBox(width: 16.0),
          Column(
            children: [
              Text(
                '必修選択区分',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusSelectionSection),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  '対象学年',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusTargetGrade),
              ],
            ),
            const SizedBox(width: 16.0),
            Column(
              children: [
                Text(
                  '単位数',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusCredit),
              ],
            ),
            const SizedBox(width: 16.0),
            Column(
              children: [
                Text(
                  '曜日・時限',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusWeekdayPeriod),
              ],
            ),
            const SizedBox(width: 16.0),
            Column(
              children: [
                Text(
                  '教室',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(timetable.syllabusClassRoom),
              ],
            ),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      Text(
        'キーワード',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusKeyword,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '授業の目標',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusClassTarget,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '学習内容',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusLearningDetail,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '授業計画',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusClassPlan,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'テキスト',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTextbook,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '参考書',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusReferenceBook,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '予習・復習について',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusPreparationReview,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '成績評価の方法･基準',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusEvaluationMethod,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'オフィスアワー',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusOfficeHour,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '担当教員からのメッセージ',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusMessage,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'アクティブ・ラーニング',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusActiveLearning,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '実務経験のある教員の有無',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTeacherPracticalExperience,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '実務経験のある教員の経歴と授業内容',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTeacherCareerClassDetail,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '教職科目区分',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTeachingProfessionSection,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '関連授業科目',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusRelatedClassSubjects,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'その他',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusOther,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '在宅授業形態',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusHomeClassStyle,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '在宅授業形態（詳細）',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusHomeClassStyleDetail,
        ),
      ),
      const SizedBox(height: 8.0),
    ],
  );
}
