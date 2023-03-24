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
  var academicYear = -1;
  var syllabusTitleID = '';
  var indexID = '';
  var targetGrade = -1;
  var semester = -1;
  var week = -1;
  var hour = -1;
  var kamokuName = '';
  var editorName = '';
  var numberingAtrib = '';
  var numberingLevel = -1;
  var numberingSubjectType = -1;
  var numberingAcademic = '';
  var freeWord = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          context.read<ApiRepository>().fetchSyllabusSearch(syllabusTitleID),
      builder: (context, AsyncSnapshot<SyllabusSearch?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Scaffold(
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
                              academicYear != -1
                                  ? academicYear.toString()
                                  : '-',
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
                                          snapshot.data!.academicYearMap.keys
                                              .toList()
                                              .reduce(min),
                                          1),
                                      lastDate: DateTime(
                                          snapshot.data!.academicYearMap.keys
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
                              syllabusTitleID != ''
                                  ? snapshot.data!
                                      .syllabusTitleIDMap[syllabusTitleID]!
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('タイトル'),
                                children:
                                    snapshot.data!.syllabusTitleIDMap.entries
                                        .map(
                                          (e) => SimpleDialogOption(
                                            onPressed: () async {
                                              setState(() {
                                                syllabusTitleID = e.key;
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
                              indexID != '' && snapshot.data!.indexIDMap != null
                                  ? snapshot.data!.indexIDMap![indexID] ?? '-'
                                  : '-',
                            ),
                            onPressed: () async => showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('フォルダ'),
                                children: snapshot.data!.indexIDMap!.entries
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
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
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
