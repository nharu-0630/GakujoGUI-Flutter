import 'package:flutter/material.dart';
import 'package:gakujo_task/api/parse.dart';
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
    return Scaffold(
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          FutureBuilder(
              future: context.watch<TimetableRepository>().getAll(),
              builder: (context, AsyncSnapshot<List<Timetable>> snapshot) {
                return snapshot.hasData
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${'月火水木金'[i]}曜日',
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
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${i + 1}限',
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => showModalBottomSheet(
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16.0))),
            context: context,
            builder: (context) => DraggableScrollableSheet(
              expand: false,
              builder: (context, controller) {
                return buildTimetableModal(context, timetable, controller);
              },
            ),
          ),
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0))),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                  color: timetable.subject.parseColor(),
                  width: 6.0,
                )),
              ),
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
                          Icons.category_rounded,
                          size: 16.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            timetable.className,
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
        ),
      ),
    );
  }
}
