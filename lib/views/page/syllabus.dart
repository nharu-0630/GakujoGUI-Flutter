import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/syllabus_search.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:provider/provider.dart';

class SyllabusPage extends StatefulWidget {
  const SyllabusPage({Key? key}) : super(key: key);

  @override
  State<SyllabusPage> createState() => _SyllabusPageState();
}

class _SyllabusPageState extends State<SyllabusPage> {
  SyllabusSearch? syllabusSearch;

  var academicYear = -1;
  var syllabusTitleID = '';
  var indexID = '';
  var targetGrade = '';
  var semester = '';
  var week = '';
  var hour = '';
  var kamokuName = '';
  var editorName = '';
  var freeWord = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      syllabusSearch =
          await context.read<ApiRepository>().fetchSyllabusSearch('');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return syllabusSearch != null
        ? Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) =>
                  [_buildAppBar(context)],
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
                            style: Theme.of(context).textTheme.titleMedium,
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
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('開講年度'),
                                  content: SizedBox(
                                    width: 360,
                                    height: 360,
                                    child: YearPicker(
                                      firstDate: DateTime(
                                          syllabusSearch!.academicYearMap.keys
                                              .toList()
                                              .reduce(min),
                                          1),
                                      lastDate: DateTime(
                                          syllabusSearch!.academicYearMap.keys
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
                                );
                              },
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              syllabusTitleID.isNotEmpty
                                  ? syllabusSearch!.syllabusTitleIDMap[
                                          syllabusTitleID] ??
                                      '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('タイトル'),
                                children:
                                    syllabusSearch!.syllabusTitleIDMap.entries
                                        .map(
                                          (e) => SimpleDialogOption(
                                            onPressed: () async {
                                              syllabusTitleID = e.key;
                                              Navigator.pop(context);
                                              syllabusSearch = await context
                                                  .read<ApiRepository>()
                                                  .fetchSyllabusSearch(
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
                            syllabusSearch = await context
                                .read<ApiRepository>()
                                .fetchSyllabusSearch(syllabusTitleID);
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              indexID.isNotEmpty &&
                                      syllabusSearch!.indexIDMap != null
                                  ? syllabusSearch!.indexIDMap![indexID] ?? '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('フォルダ'),
                                children: syllabusSearch!.indexIDMap?.entries
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              targetGrade.isNotEmpty
                                  ? syllabusSearch!
                                          .targetGradeMap[targetGrade] ??
                                      '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('対象学年'),
                                children: syllabusSearch!.targetGradeMap.entries
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              week.isNotEmpty
                                  ? syllabusSearch!.weekMap[week] ?? '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('曜日'),
                                children: syllabusSearch!.weekMap.entries
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            child: Text(
                              hour.isNotEmpty
                                  ? syllabusSearch!.hourMap[hour] ?? '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('時限'),
                                children: syllabusSearch!.hourMap.entries
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => kamokuName = value),
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => editorName = value),
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => freeWord = value),
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
                        var _ = await context
                            .read<ApiRepository>()
                            .fetchSyllabusResult(
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
            body: Center(
              child: CircularProgressIndicator(),
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
}
