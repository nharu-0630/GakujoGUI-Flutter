import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final weekList = [
    '日',
    '月',
    '火',
    '水',
    '木',
    '金',
    '土',
    '日',
    '月',
    '火',
    '水',
    '木',
    '金',
    '土'
  ];
  final dayList = [
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30'
  ];
  var selected = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: selected == index
                          ? Colors.grey.withOpacity(0.1)
                          : null),
                  child: Column(
                    children: [
                      Text(
                        weekList[index],
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                selected == index ? Colors.black : Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayList[index],
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                selected == index ? Colors.black : Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
          separatorBuilder: ((_, index) => const SizedBox(width: 5)),
          itemCount: weekList.length),
    );
  }
}
