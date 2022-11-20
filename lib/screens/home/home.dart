import 'package:flutter/material.dart';
import 'package:gakujo_task/screens/home/widgets/tasks.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GoPremium(),
          Container(
            padding: const EdgeInsets.all(15),
            child: const Text(
              'タスク',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Tasks(),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundColor: Colors.black,
        onPressed: () {},
        child: const Icon(
          Icons.sync,
          size: 35,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(children: [
        Container(
          height: 45,
          width: 45,
          // margin: const EdgeInsets.only(left: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/images/avatar.png'),
          ),
        ),
        const SizedBox(width: 10),
        const Text('Hi, xyzyxJP!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ))
      ]),
      // actions: const [
      //   Icon(
      //     Icons.more_vert,
      //     color: Colors.black,
      //     size: 40,
      //   )
      // ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10)
          ]),
      child: Stack(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
              backgroundColor: Colors.white,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey.withOpacity(0.5),
              items: const [
                BottomNavigationBarItem(
                    label: 'Home',
                    icon: Icon(
                      Icons.home_rounded,
                      size: 30,
                    )),
                BottomNavigationBarItem(
                    label: 'Settings',
                    icon: Icon(
                      Icons.settings_rounded,
                      size: 30,
                    )),
              ]),
        ),
        const Positioned(
            right: 10, bottom: 10, child: Text('Client Version: 1.0.0.0'))
      ]),
    );
  }
}
