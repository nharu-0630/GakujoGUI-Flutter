import 'package:flutter/material.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/models/grade.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<GradeRepository>().getAll(),
      builder: (context, AsyncSnapshot<List<Grade>> snapshot) {
        if (snapshot.hasData) {
          _grades = snapshot.data!;
          _grades.sort(((a, b) => b.compareTo(a)));
          return Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxScrolled) =>
                    [_buildAppBar(context)],
                body: TabBarView(
                  children: [_buildList(context), Container()],
                ),
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

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ApiRepository>().fetchGrades(),
      child: _grades.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.school_rounded,
                            size: 48.0,
                          ),
                        ),
                        Text(
                          '成績情報はありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _searchStatus ? _suggestGrades.length : _grades.length,
              itemBuilder: (context, index) => _searchStatus
                  ? _buildCard(context, _suggestGrades[index])
                  : _buildCard(context, _grades[index]),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                  icon: const Icon(Icons.close_rounded),
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
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.view_list_rounded)),
                Tab(icon: Icon(Icons.bar_chart_rounded)),
              ],
            ),
            buildAppBarBottom(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Grade grade) {
    return ListTile(
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
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Visibility(
            visible: grade.gp != null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                grade.gp.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            grade.teacher.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              grade.selectionSection.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Expanded(child: SizedBox()),
          Text(
            DateFormat('yyyy/MM/dd', 'ja')
                .format(grade.reportDateTime.toLocal()),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
