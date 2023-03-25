import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:gakujo_gui/views/common/widget.dart';
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
      onTap: () async {},
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
