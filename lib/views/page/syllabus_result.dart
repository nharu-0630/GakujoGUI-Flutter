import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/syllabus_detail.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet/side_sheet.dart';

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
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) =>
            [_buildAppBar(context)],
        body: result == null
            ? LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: result!.length,
                itemBuilder: (context, index) =>
                    _buildCard(context, result![index]),
              ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCard(BuildContext context, SyllabusResult syllabus) {
    return ListTile(
      onTap: () async =>
          MediaQuery.of(context).orientation == Orientation.portrait
              ? showModalBottomSheet(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  isScrollControlled: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(0.0))),
                  context: context,
                  builder: (context) => buildSyllabusModal(context, syllabus),
                )
              : SideSheet.right(
                  sheetColor: Theme.of(context).colorScheme.surface,
                  body: SizedBox(
                    width: MediaQuery.of(context).size.width * .6,
                    child: buildSyllabusModal(context, syllabus),
                  ),
                  context: context,
                ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              syllabus.teacherName,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            syllabus.titleName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              syllabus.subjectName,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            syllabus.indexName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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

Widget buildSyllabusModal(BuildContext context, SyllabusResult query) {
  return FutureBuilder(
    future: context.read<ApiRepository>().fetchSyllabusDetail(query),
    builder: (context, AsyncSnapshot<SyllabusDetail?> snapshot) {
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
                    _buildIconItem(
                        context, LineIcons.shapes, syllabus.className),
                    _buildIconItem(
                        context, LineIcons.mapPin, syllabus.classRoom),
                    _buildIconItem(
                        context, LineIcons.userGraduate, syllabus.teacher),
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
                    _buildShortItem(context, '担当教員名', syllabus.teacher),
                    _buildShortItem(context, '所属等', syllabus.affiliation),
                    _buildShortItem(context, '研究室', syllabus.researchRoom),
                    _buildShortItem(context, '分担教員名', syllabus.sharingTeacher),
                    _buildShortItem(context, 'クラス', syllabus.className),
                    _buildShortItem(context, '学期', syllabus.semesterName),
                    _buildShortItem(
                        context, '必修選択区分', syllabus.selectionSection),
                    _buildShortItem(context, '対象学年', syllabus.targetGrade),
                    _buildShortItem(context, '単位数', syllabus.credit),
                    _buildShortItem(context, '曜日・時限', syllabus.weekdayPeriod),
                    _buildShortItem(context, '教室', syllabus.classRoom),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Divider(thickness: 2.0),
                ),
                ..._buildLongItem(context, 'キーワード', syllabus.keyword),
                ..._buildLongItem(context, '授業の目標', syllabus.classTarget),
                ..._buildLongItem(context, '学習内容', syllabus.learningDetail),
                ..._buildLongItem(context, '授業計画', syllabus.classPlan),
                ..._buildLongItem(context, 'テキスト', syllabus.textbook),
                ..._buildLongItem(context, '参考書', syllabus.referenceBook),
                ..._buildLongItem(
                    context, '予習・復習について', syllabus.preparationReview),
                ..._buildLongItem(
                    context, '成績評価の方法･基準', syllabus.evaluationMethod),
                ..._buildLongItem(context, 'オフィスアワー', syllabus.officeHour),
                ..._buildLongItem(context, '担当教員からのメッセージ', syllabus.message),
                ..._buildLongItem(
                    context, 'アクティブ・ラーニング', syllabus.activeLearning),
                ..._buildLongItem(context, '実務経験のある教員の有無',
                    syllabus.teacherPracticalExperience),
                ..._buildLongItem(context, '実務経験のある教員の経歴と授業内容',
                    syllabus.teacherCareerClassDetail),
                ..._buildLongItem(
                    context, '教職科目区分', syllabus.teachingProfessionSection),
                ..._buildLongItem(
                    context, '関連授業科目', syllabus.relatedClassSubjects),
                ..._buildLongItem(context, 'その他', syllabus.other),
                ..._buildLongItem(context, '在宅授業形態', syllabus.homeClassStyle),
                ..._buildLongItem(
                    context, '在宅授業形態（詳細）', syllabus.homeClassStyleDetail),
              ],
            )
          : const Center(child: CircularProgressIndicator());
    },
  );
}
