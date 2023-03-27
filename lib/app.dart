import 'package:flutter/material.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:gakujo_gui/views/home/home.dart';
import 'package:gakujo_gui/views/page/timetable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import 'api/provide.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiRepository>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: App.scaffoldMessengerKey,
      navigatorKey: App.navigatorKey,
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
      title: 'GakujoGUI',
      home: Scaffold(
        key: App.scaffoldKey,
        drawer: buildDrawer(),
        appBar: buildAppBar(context, App.scaffoldKey),
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
          icon: Icon(LineIcons.home),
          label: 'ホーム',
          tooltip: 'ホーム',
        ),
        NavigationDestination(
          icon: Icon(LineIcons.calendar),
          label: '時間割',
          tooltip: '時間割',
        ),
      ],
    );
  }
}
