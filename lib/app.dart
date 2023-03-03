import 'package:flutter/material.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:gakujo_task/views/home/home.dart';
import 'package:gakujo_task/views/page/timetable.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

var scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
var navigatorKey = GlobalKey<NavigatorState>();
var scaffoldKey = GlobalKey<ScaffoldState>();

class _AppState extends State<App> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Gakujo Task',
      home: Scaffold(
        key: scaffoldKey,
        drawer: buildDrawer(context),
        appBar: buildAppBar(context, scaffoldKey),
        body: const [
          HomeWidget(),
          TimetablePage(),
        ][_index],
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      onDestinationSelected: (int value) => setState(() => _index = value),
      selectedIndex: _index,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
          tooltip: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Timetable',
          tooltip: 'Timetable',
        ),
      ],
    );
  }
}
