import 'package:flutter/material.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/timetable.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:provider/provider.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<TimetableRepository>().getAll(),
      builder: (context, AsyncSnapshot<List<Timetable>> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) =>
                  [_buildAppBar(context)],
              body: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.0),
                  3: FlexColumnWidth(1.0),
                  4: FlexColumnWidth(1.0),
                  5: FlexColumnWidth(1.0),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  for (var i = 0; i < 5; i++)
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${i + 1}限',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        for (var j = 0; j < 5; j++)
                          if (snapshot.data!
                              .any((e) => e.weekday == j && e.period == i))
                            _buildCell(
                                context,
                                snapshot.data!.firstWhere(
                                    (e) => e.weekday == j && e.period == i))
                          else
                            const TableCell(child: SizedBox()),
                      ],
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      title: const Text('個人時間割'),
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCell(BuildContext context, Timetable timetable) {
    return TableCell(
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
          context: context,
          builder: (context) => DraggableScrollableSheet(
            expand: false,
            builder: (context, controller) {
              return buildTimetableModal(context, timetable, controller);
            },
          ),
        ),
        child: Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        timetable.subject,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        timetable.classRoom,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        timetable.teacher,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
