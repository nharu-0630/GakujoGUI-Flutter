import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final weekList = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', "Sat"];
  final dayList = ['24', '25', '26', '27', '28', '29', '30'];
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
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => selected = index),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
                            color:
                                selected == index ? Colors.black : Colors.grey),
                      ),
                      const SizedBox(height: 5),
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
