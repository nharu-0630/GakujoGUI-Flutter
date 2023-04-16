import 'dart:collection';

import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/gpa.dart';
import 'package:gakujo_gui/models/grade.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class GradePage extends StatefulWidget {
  const GradePage({Key? key}) : super(key: key);

  @override
  State<GradePage> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  bool _searchStatus = false;
  List<Grade> _grades = [];
  List<Grade> _suggestGrades = [];
  Gpa _gpa = Gpa.init();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.watch<GradeRepository>().getAll(),
        context.watch<GpaRepository>().load()
      ]),
      builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          _grades = snapshot.data![0];
          _grades.sort(((a, b) => b.compareTo(a)));
          _gpa = snapshot.data![1];
          return Scaffold(
            floatingActionButton: buildFloatingActionButton(
              onPressed: context.read<ApiRepository>().fetchGrades,
              iconData: KIcons.update,
            ),
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (_, __) => [_buildAppBar()],
                body: TabBarView(
                  children: [_buildGrade(), _buildGpas()],
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildGrade() {
    return Builder(builder: (context) {
      return RefreshIndicator(
        onRefresh: () async => context.read<ApiRepository>().fetchGrades(),
        child: _grades.isEmpty
            ? buildCenterItemLayoutBuilder(KIcons.grade, '成績情報はありません')
            : ListView.builder(
                controller: ScrollController(),
                padding: const EdgeInsets.only(top: 8.0),
                itemCount:
                    _searchStatus ? _suggestGrades.length : _grades.length,
                itemBuilder: (_, index) => _searchStatus
                    ? _buildCard(_suggestGrades[index])
                    : _buildCard(_grades[index]),
              ),
      );
    });
  }

  Widget _buildImageItem(String title, String key, String? image) {
    return Builder(builder: (context) {
      return Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8.0),
          image != null
              ? Image(
                  image: CachedMemoryImageProvider(
                    key,
                    base64: image,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      );
    });
  }

  Widget _buildGpas() {
    return Builder(builder: (context) {
      return RefreshIndicator(
        onRefresh: () async => context.read<ApiRepository>().fetchGrades(),
        child: ListView(
          controller: ScrollController(),
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildGpaChart(_gpa.departmentGpas),
            const SizedBox(height: 16.0),
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
                buildShortItem('学年', _gpa.facultyGrade),
                buildShortItem('累積GPA', _gpa.facultyGpa.toString()),
                buildShortItem('学科内順位',
                    '${_gpa.departmentRankNumber} / ${_gpa.departmentRankDenom}'),
                buildShortItem('コース内順位',
                    '${_gpa.courseRankNumber} / ${_gpa.courseRankDenom}'),
                buildShortItem('算出日',
                    _gpa.facultyCalculationDate.toLocal().toDateString()),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Divider(thickness: 2.0),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32.0,
              runSpacing: 8.0,
              children: [
                _buildImageItem('学部', 'FacultyImage', _gpa.facultyImage),
                _buildImageItem('学科', 'DepartmentImage', _gpa.departmentImage),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildGpaChart(Map<String, double> gpas) {
    gpas = SplayTreeMap.from(gpas, (a, b) {
      int yearA = int.parse(
          a.replaceAll('GPA値', '').split('　')[0].replaceAll('年度', ''));
      int yearB = int.parse(
          b.replaceAll('GPA値', '').split('　')[0].replaceAll('年度', ''));
      int compare1 = yearA.compareTo(yearB);
      if (compare1 != 0) return compare1;
      int termA = a.replaceAll('GPA値', '').split('　')[1] == '前期' ? 1 : 2;
      int termB = b.replaceAll('GPA値', '').split('　')[1] == '前期' ? 1 : 2;
      int compare2 = termA.compareTo(termB);
      if (compare2 != 0) return compare2;
      return 1;
    });
    return gpas.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: LineChart(
                  LineChartData(
                    maxY: 4.5,
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: gpas.entries
                            .mapIndexed((index, element) =>
                                FlSpot(index.toDouble(), element.value))
                            .toList(),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF50E4FF),
                            Color(0xFF2196F3),
                          ],
                        ),
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: false,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF50E4FF),
                              const Color(0xFF2196F3),
                            ].map((color) => color.withOpacity(0.3)).toList(),
                          ),
                        ),
                      )
                    ],
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xFF333C43)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              gpas.keys
                                  .elementAt(value.toInt())
                                  .replaceAll('GPA値', '')
                                  .replaceAll('　', '\n'),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 32.0,
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) => Text(
                            value.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 150),
                  swapAnimationCurve: Curves.linear,
                ),
              ),
            ),
          )
        : const SizedBox();
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
        title: _searchStatus
            ? TextField(
                onChanged: (value) => setState(() => _suggestGrades = _grades
                    .where((e) =>
                        e.subject.toLowerCase().contains(value.toLowerCase()))
                    .toList()),
                autofocus: true,
                textInputAction: TextInputAction.search,
              )
            : const Text('成績情報'),
        actions: _searchStatus
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: (() => setState(() => _searchStatus = false)),
                    icon: Icon(KIcons.close),
                  ),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: (() => setState(() {
                          _searchStatus = true;
                          _suggestGrades = [];
                        })),
                    icon: Icon(KIcons.search),
                  ),
                ),
              ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(icon: Icon(LineIcons.bars)),
                  Tab(icon: Icon(LineIcons.barChart)),
                ],
              ),
              buildAppBarBottom(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCard(Grade grade) {
    return Builder(builder: (context) {
      return ListTile(
        onTap: () {},
        title: Row(
          children: [
            Expanded(
              child: Text(
                grade.subject,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              grade.evaluation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Visibility(
              visible: grade.score != null,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  grade.score.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            Visibility(
              visible: grade.gp != null,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  grade.gp.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              grade.teacher.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                grade.selectionSection.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Expanded(child: SizedBox()),
            Text(
              grade.reportDateTime.toLocal().toDateString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    });
  }
}
