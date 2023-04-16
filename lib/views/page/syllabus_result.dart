import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/syllabus_detail.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class SyllabusResultPage extends StatefulWidget {
  const SyllabusResultPage({
    Key? key,
    required this.academicYear,
    required this.syllabusTitleID,
    required this.indexID,
    required this.targetGrade,
    required this.semester,
    required this.week,
    required this.hour,
    required this.kamokuName,
    required this.editorName,
    required this.freeWord,
  }) : super(key: key);

  final int academicYear;
  final String syllabusTitleID;
  final String indexID;
  final String targetGrade;
  final String semester;
  final String week;
  final String hour;
  final String kamokuName;
  final String editorName;
  final String freeWord;

  @override
  State<SyllabusResultPage> createState() => _SyllabusResultPageState();
}

class _SyllabusResultPageState extends State<SyllabusResultPage> {
  List<SyllabusResult>? result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      result = await context.read<ApiRepository>().fetchSyllabusResult(
            academicYear: widget.academicYear,
            syllabusTitleID: widget.syllabusTitleID,
            indexID: widget.indexID,
            targetGrade: widget.targetGrade,
            semester: widget.semester,
            week: widget.week,
            hour: widget.hour,
            kamokuName: widget.kamokuName,
            editorName: widget.editorName,
            freeWord: widget.freeWord,
          );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return result != null
        ? Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (_, __) => [_buildAppBar()],
              body: result!.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0),
                      itemCount: result!.length,
                      itemBuilder: (_, index) => _buildCard(result![index]),
                    )
                  : buildCenterItemLayoutBuilder(
                      KIcons.syllabus, '検索条件に合致するシラバスはありません'),
            ),
          )
        : const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget _buildAppBar() {
    return Builder(builder: (context) {
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
        title: const Text('シラバス'),
        bottom: buildAppBarBottom(),
      );
    });
  }

  Widget _buildCard(SyllabusResult syllabus) {
    return Builder(builder: (context) {
      return ListTile(
        onTap: () async =>
            showModalOnTap(context, buildSyllabusModal(syllabus)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                syllabus.subjectName,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              syllabus.titleName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                syllabus.teacherName,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                syllabus.className,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Text(
              syllabus.indexName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    });
  }
}

Widget buildSyllabusModal(SyllabusResult query) {
  return Builder(builder: (context) {
    return FutureBuilder(
      future: context.read<ApiRepository>().fetchSyllabusDetail(query),
      builder: (_, AsyncSnapshot<SyllabusDetail?> snapshot) {
        var syllabus = snapshot.data;
        return syllabus != null
            ? ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      syllabus.subject,
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
                      buildIconItem(LineIcons.shapes, syllabus.className),
                      buildIconItem(LineIcons.mapPin, syllabus.classRoom),
                      buildIconItem(LineIcons.userGraduate, syllabus.teacher),
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
                      buildShortItem('担当教員名', syllabus.teacher),
                      buildShortItem('所属等', syllabus.affiliation),
                      buildShortItem('研究室', syllabus.researchRoom),
                      buildShortItem('分担教員名', syllabus.sharingTeacher),
                      buildShortItem('クラス', syllabus.className),
                      buildShortItem('学期', syllabus.semesterName),
                      buildShortItem('必修選択区分', syllabus.selectionSection),
                      buildShortItem('対象学年', syllabus.targetGrade),
                      buildShortItem('単位数', syllabus.credit),
                      buildShortItem('曜日・時限', syllabus.weekdayPeriod),
                      buildShortItem('教室', syllabus.classRoom),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Divider(thickness: 2.0),
                  ),
                  ...buildLongItem('キーワード', syllabus.keyword),
                  ...buildLongItem('授業の目標', syllabus.classTarget),
                  ...buildLongItem('学習内容', syllabus.learningDetail),
                  ...buildLongItem('授業計画', syllabus.classPlan),
                  ...buildLongItem('テキスト', syllabus.textbook),
                  ...buildLongItem('参考書', syllabus.referenceBook),
                  ...buildLongItem('予習・復習について', syllabus.preparationReview),
                  ...buildLongItem('成績評価の方法･基準', syllabus.evaluationMethod),
                  ...buildLongItem('オフィスアワー', syllabus.officeHour),
                  ...buildLongItem('担当教員からのメッセージ', syllabus.message),
                  ...buildLongItem('アクティブ・ラーニング', syllabus.activeLearning),
                  ...buildLongItem(
                      '実務経験のある教員の有無', syllabus.teacherPracticalExperience),
                  ...buildLongItem(
                      '実務経験のある教員の経歴と授業内容', syllabus.teacherCareerClassDetail),
                  ...buildLongItem(
                      '教職科目区分', syllabus.teachingProfessionSection),
                  ...buildLongItem('関連授業科目', syllabus.relatedClassSubjects),
                  ...buildLongItem('その他', syllabus.other),
                  ...buildLongItem('在宅授業形態', syllabus.homeClassStyle),
                  ...buildLongItem('在宅授業形態（詳細）', syllabus.homeClassStyleDetail),
                ],
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  });
}
