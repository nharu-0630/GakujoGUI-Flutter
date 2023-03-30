import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/syllabus_parameters.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:gakujo_gui/views/page/syllabus_result.dart';
import 'package:provider/provider.dart';

class SyllabusSearchPage extends StatefulWidget {
  const SyllabusSearchPage({Key? key}) : super(key: key);

  @override
  State<SyllabusSearchPage> createState() => _SyllabusSearchPageState();
}

class _SyllabusSearchPageState extends State<SyllabusSearchPage> {
  SyllabusParameters? parameters;

  int academicYear = -1;
  String syllabusTitleID = '';
  String indexID = '';
  String targetGrade = '';
  String semester = '';
  String week = '';
  String hour = '';
  String kamokuName = '';
  String editorName = '';
  String freeWord = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      parameters =
          await context.read<ApiRepository>().fetchSyllabusParameters('');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return parameters != null
        ? Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (_, __) => [_buildAppBar()],
              body: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '開講年度',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              academicYear != -1 ? '$academicYear年度' : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('開講年度'),
                                content: SizedBox(
                                  width: 360,
                                  height: 360,
                                  child: YearPicker(
                                    firstDate: DateTime(
                                        parameters!.academicYearMap.keys
                                            .toList()
                                            .reduce(min),
                                        1),
                                    lastDate: DateTime(
                                        parameters!.academicYearMap.keys
                                            .toList()
                                            .reduce(max),
                                        1),
                                    initialDate: academicYear != -1
                                        ? DateTime(academicYear)
                                        : DateTime.now(),
                                    selectedDate: academicYear != -1
                                        ? DateTime(academicYear)
                                        : DateTime.now(),
                                    onChanged: (DateTime dateTime) {
                                      setState(() {
                                        academicYear = dateTime.year;
                                        Navigator.pop(context);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(KIcons.close),
                          onPressed: () => setState(() => academicYear = -1),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'タイトル',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              syllabusTitleID.isNotEmpty
                                  ? parameters!.syllabusTitleIDMap[
                                          syllabusTitleID] ??
                                      '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('タイトル'),
                                children: parameters!.syllabusTitleIDMap.entries
                                    .map(
                                      (e) => SimpleDialogOption(
                                        onPressed: () async {
                                          syllabusTitleID = e.key;
                                          Navigator.pop(context);
                                          parameters = await context
                                              .read<ApiRepository>()
                                              .fetchSyllabusParameters(
                                                  syllabusTitleID);
                                          setState(() {});
                                        },
                                        child: Text(e.value),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(KIcons.close),
                          onPressed: () async {
                            syllabusTitleID = '';
                            parameters = await context
                                .read<ApiRepository>()
                                .fetchSyllabusParameters(syllabusTitleID);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'フォルダ',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              indexID.isNotEmpty &&
                                      parameters!.indexIDMap != null
                                  ? parameters!.indexIDMap![indexID] ?? '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('フォルダ'),
                                children: parameters!.indexIDMap?.entries
                                        .map(
                                          (e) => SimpleDialogOption(
                                            onPressed: () async {
                                              setState(() {
                                                indexID = e.key;
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Text(e.value),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(KIcons.close),
                          onPressed: () => setState(() => indexID = ''),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '対象学年',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              targetGrade.isNotEmpty
                                  ? parameters!.targetGradeMap[targetGrade] ??
                                      '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('対象学年'),
                                children: parameters!.targetGradeMap.entries
                                    .map(
                                      (e) => SimpleDialogOption(
                                        onPressed: () async {
                                          setState(() {
                                            targetGrade = e.key;
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(e.value),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(KIcons.close),
                          onPressed: () => setState(() => targetGrade = ''),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '曜日',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              week.isNotEmpty
                                  ? parameters!.weekMap[week] ?? '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('曜日'),
                                children: parameters!.weekMap.entries
                                    .map(
                                      (e) => SimpleDialogOption(
                                        onPressed: () async {
                                          setState(() {
                                            week = e.key;
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(e.value),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(KIcons.close),
                          onPressed: () => setState(() => week = ''),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '時限',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              hour.isNotEmpty
                                  ? parameters!.hourMap[hour] ?? '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('時限'),
                                children: parameters!.hourMap.entries
                                    .map(
                                      (e) => SimpleDialogOption(
                                        onPressed: () async {
                                          setState(() {
                                            hour = e.key;
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(e.value),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(KIcons.close),
                          onPressed: () => setState(() => hour = ''),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '授業科目名',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => kamokuName = value),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '担当教員名',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => editorName = value),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'フリーワード',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => freeWord = value),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SyllabusResultPage(
                              academicYear: academicYear,
                              syllabusTitleID: syllabusTitleID,
                              indexID: indexID,
                              targetGrade: targetGrade,
                              semester: semester,
                              week: week,
                              hour: hour,
                              kamokuName: kamokuName,
                              editorName: editorName,
                              freeWord: freeWord,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(KIcons.search),
                            const SizedBox(width: 8.0),
                            Text(
                              '検索',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
}
