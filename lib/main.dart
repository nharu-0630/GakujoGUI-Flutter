import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/screens/home/home.dart';
import 'package:gakujo_task/screens/settings/settings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var api;
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ja');
    dotenv.load(fileName: '.env');
    api = Api(2022, 2, dotenv.env['USERNAME']!, dotenv.env['PASSWORD']!);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gakujo Task',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: [
          const HomePage(),
          const SettingsPage(),
        ][_index],
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          backgroundColor: Colors.black,
          onPressed: () {},
          child: const Icon(
            Icons.sync,
            size: 35,
          ),
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
              currentIndex: _index,
              onTap: (value) => setState(() => _index = value),
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
        ),
      ]),
    );
  }
}
