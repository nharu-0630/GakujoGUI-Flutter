import 'package:badges/badges.dart' as badges;
import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/questionnaire.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/settings.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:gakujo_gui/views/home/home.dart';
import 'package:gakujo_gui/views/home/timetable.dart';
import 'package:gakujo_gui/views/page/class_link.dart';
import 'package:gakujo_gui/views/page/contact.dart';
import 'package:gakujo_gui/views/page/grade.dart';
import 'package:gakujo_gui/views/page/questionnaire.dart';
import 'package:gakujo_gui/views/page/quiz.dart';
import 'package:gakujo_gui/views/page/report.dart';
import 'package:gakujo_gui/views/page/settings.dart';
import 'package:gakujo_gui/views/page/shared_file.dart';
import 'package:gakujo_gui/views/page/syllabus_search.dart';
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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiRepository>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (
        ColorScheme? lightDynamic,
        ColorScheme? darkDynamic,
      ) =>
          MaterialApp(
        scaffoldMessengerKey: App.scaffoldMessengerKey,
        navigatorKey: App.navigatorKey,
        themeMode: ThemeMode.system,
        theme: buildThemeData(lightDynamic),
        darkTheme: buildDarkTheme(darkDynamic),
        debugShowCheckedModeBanner: false,
        title: 'GakujoGUI',
        home: Scaffold(
          floatingActionButton: _buildFloatingActionButton(),
          key: App.scaffoldKey,
          drawer: _buildDrawer(),
          appBar: _buildAppBar(),
          body: PageView(
            controller: _pageController,
            children: const [
              HomeWidget(),
              TimetablePage(),
            ],
            onPageChanged: (index) => setState(() => _index = index),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return SpeedDial(
      childMargin: const EdgeInsets.all(8.0),
      animatedIcon: AnimatedIcons.menu_close,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
                      context.read<ApiRepository>().fetchQuestionnaires(),
                  child: const Text('授業アンケート'),
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
    );
  }

  ThemeData buildThemeData(ColorScheme? lightDynamic) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightDynamic ??
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B66B1),
            brightness: Brightness.light,
          ),
      textTheme: GoogleFonts.bizUDPGothicTextTheme(
        ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: lightDynamic ??
              ColorScheme.fromSeed(
                seedColor: const Color(0xFF3B66B1),
                brightness: Brightness.light,
              ),
        ).textTheme,
      ),
    );
  }

  ThemeData buildDarkTheme(ColorScheme? darkDynamic) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkDynamic ??
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B66B1),
            brightness: Brightness.dark,
          ),
      textTheme: GoogleFonts.bizUDPGothicTextTheme(
        ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: darkDynamic ??
              ColorScheme.fromSeed(
                seedColor: const Color(0xFF3B66B1),
                brightness: Brightness.dark,
              ),
        ).textTheme,
      ),
    );
  }

  Widget _buildDrawer() {
    return Builder(builder: (context) {
      return FutureBuilder(
          future: Future.wait([
            context.watch<SettingsRepository>().load(),
            context.watch<ReportRepository>().getSubmittable(),
            context.watch<QuizRepository>().getSubmittable(),
            context.watch<QuestionnaireRepository>().getSubmittable(),
          ]),
          builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
            var settings = snapshot.data?[0] as Settings?;
            var reportCount = (snapshot.data?[1] ?? []).length;
            var quizCount = (snapshot.data?[2] ?? []).length;
            var questionnaireCount = (snapshot.data?[3] ?? []).length;
            return Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero),
              ),
              child: ListView(
                children: [
                  SizedBox(
                    child: DrawerHeader(
                      child: Column(
                        children: [
                          Text(
                            'GakujoGUI',
                            style: GoogleFonts.roboto(
                                textStyle:
                                    Theme.of(context).textTheme.titleLarge),
                          ),
                          const SizedBox(height: 16.0),
                          settings != null
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(LineIcons.userClock),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          settings.lastLoginTime
                                              .toLocal()
                                              .toDateTimeString(),
                                          style: GoogleFonts.roboto(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        const Icon(
                                            LineIcons.identificationBadge),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          settings.username ?? '',
                                          style: GoogleFonts.roboto(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        const Icon(LineIcons.userShield),
                                        const SizedBox(width: 16.0),
                                        Text(
                                          settings.accessEnvironmentName ?? '',
                                          style: GoogleFonts.roboto(
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          KIcons.contact,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '授業連絡',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ContactPage(null)));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        badges.Badge(
                          showBadge: reportCount > 0,
                          ignorePointer: true,
                          badgeContent: Text(reportCount.toString()),
                          badgeStyle: const badges.BadgeStyle(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                          ),
                          position: badges.BadgePosition.bottomEnd(end: -6.0),
                          child: Icon(
                            KIcons.report,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          'レポート',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ReportPage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        badges.Badge(
                          showBadge: quizCount > 0,
                          ignorePointer: true,
                          badgeContent: Text(quizCount.toString()),
                          badgeStyle: const badges.BadgeStyle(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                          ),
                          position: badges.BadgePosition.bottomEnd(end: -6.0),
                          child: Icon(
                            KIcons.quiz,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '小テスト',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuizPage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          KIcons.sharedFile,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '授業共有ファイル',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SharedFilePage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          KIcons.classLink,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '授業リンク',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ClassLinkPage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        badges.Badge(
                          showBadge: questionnaireCount > 0,
                          ignorePointer: true,
                          badgeContent: Text(questionnaireCount.toString()),
                          badgeStyle: const badges.BadgeStyle(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                          ),
                          position: badges.BadgePosition.bottomEnd(end: -6.0),
                          child: Icon(
                            KIcons.questionnaire,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '授業アンケート',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const QuestionnairePage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          KIcons.grade,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '成績情報',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GradePage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          KIcons.syllabus,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          'シラバス',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SyllabusSearchPage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          KIcons.settings,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '設定',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SettingsPage()));
                    },
                  ),
                ],
              ),
            );
          });
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      leading: FutureBuilder(
        future: context.watch<SettingsRepository>().load(),
        builder: (_, AsyncSnapshot<Settings> snapshot) => snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: snapshot.data?.profileImage != null
                    ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () =>
                              App.scaffoldKey.currentState?.openDrawer(),
                          child: CircleAvatar(
                            backgroundImage: CachedMemoryImageProvider(
                              'ProfileImage',
                              base64: snapshot.data?.profileImage,
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: () =>
                            App.scaffoldKey.currentState?.openDrawer(),
                        icon: const Icon(LineIcons.user),
                      ),
              )
            : const SizedBox.shrink(),
      ),
      centerTitle: false,
      title: FutureBuilder(
        future: context.watch<SettingsRepository>().load(),
        builder: (_, AsyncSnapshot<Settings> snapshot) => Text(
          snapshot.hasData
              ? snapshot.data?.fullName == null
                  ? 'アカウント情報なし'
                  : '${snapshot.data?.fullName}さん'
              : 'アカウント情報なし',
        ),
      ),
      bottom: buildAppBarBottom(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      height: 54.0,
      onDestinationSelected: (int index) {
        setState(() => _index = index);
        _pageController.jumpToPage(index);
      },
      selectedIndex: _index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
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
