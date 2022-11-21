import 'package:flutter/material.dart';
import 'package:gakujo_task/screens/home/widgets/messages.dart';
import 'package:gakujo_task/screens/home/widgets/status.dart';
import 'package:gakujo_task/screens/home/widgets/subjects.dart';
import 'package:gakujo_task/screens/home/widgets/tasks.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../api/api.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Status(),
              StickyHeader(
                header: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(15),
                  child: const Text(
                    'タスク',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                content: Tasks(),
              ),
              StickyHeader(
                  header: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          child: const Text(
                            'メッセージ',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                                height: 60,
                                child: Expanded(child: RecentSubjects())),
                          ),
                        ),
                      ],
                    ),
                  ),
                  content: Messages()),
              const SizedBox(height: 15)
            ],
          ),
        ),
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
        SizedBox(
          height: 45,
          width: 45,
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
            )),
      ]),
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
        Positioned(
          right: 10,
          bottom: 10,
          child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
              if (!snapshot.hasData) {
                return Text(
                  'Client Version: \nAPI Version: ',
                  style: TextStyle(color: Colors.grey[700]),
                );
              }
              return Text(
                'Client Version: ${snapshot.data!.version}\nAPI Version: ${Api.version}',
                style: TextStyle(color: Colors.grey[700]),
              );
            },
          ),
          // Text(
          //   'Client Version: \nAPI Version: ',
          //   style: TextStyle(color: Colors.grey[700]),
          // )
        ),
      ]),
    );
  }
}
