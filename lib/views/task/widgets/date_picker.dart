import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({Key? key}) : super(key: key);

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  var selected = 0;

  @override
  Widget build(BuildContext context) {
    final startDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final endDate = startDate.subtract(const Duration(days: 60));
    final dateList = List<DateTime>.generate(
        startDate.difference(endDate).inDays,
        (i) => startDate.add(Duration(days: i)));
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => selected = index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: selected == index
                          ? Colors.grey.withOpacity(0.1)
                          : null),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.E('ja').format(dateList[index]),
                        style: TextStyle(
                            fontSize: 12,
                            color: (dateList[index].weekday == 6
                                    ? Colors.blueAccent
                                    : dateList[index].weekday == 7
                                        ? Colors.redAccent
                                        : Colors.black)
                                .withOpacity(selected == index ? 1 : 0.3)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateList[index].day.toString(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                                .withOpacity(selected == index ? 1 : 0.3)),
                      )
                    ],
                  ),
                ),
              ),
          separatorBuilder: ((_, index) => const SizedBox(width: 5)),
          itemCount: dateList.length),
    );
  }
}
