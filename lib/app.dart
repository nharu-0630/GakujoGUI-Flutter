import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:gakujo_gui/views/home/home.dart';
import 'package:gakujo_gui/views/home/timetable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = 0;

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
        textTheme: GoogleFonts.bizUDPGothicTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.bizUDPGothicTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'GakujoGUI',
      home: Scaffold(
        floatingActionButton: SpeedDial(
          childMargin: const EdgeInsets.all(8.0),
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: const Icon(LineIcons.alternateSignIn),
              label: 'ログイン',
              onTap: () async => context.read<ApiRepository>().fetchLogin(),
            ),
            SpeedDialChild(
              child: Icon(KIcons.update),
              label: '更新',
              onTap: () async => showDialog(
                context: App.navigatorKey.currentState!.overlay!.context,
                builder: (_) => SimpleDialog(
                  title: const Text('更新'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchSubjects(),
                      child: const Text('授業科目'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchContacts(),
                      child: const Text('授業連絡'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchReports(),
                      child: const Text('レポート'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchQuizzes(),
                      child: const Text('小テスト'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchSharedFiles(),
                      child: const Text('授業共有ファイル'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchClassLinks(),
                      child: const Text('授業リンク'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchGrades(),
                      child: const Text('成績情報'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async =>
                          context.read<ApiRepository>().fetchTimetables(),
                      child: const Text('個人時間割'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
