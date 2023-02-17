import 'package:flutter/material.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/home/home.dart';
import 'package:gakujo_task/views/settings/settings.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();

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
        body: const [
          HomeWidget(),
          SettingsWidget(),
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
            icon: Icon(Icons.home_rounded), label: 'Home', tooltip: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
            tooltip: 'Settings'),
      ],
    );
  }
}

PreferredSize buildAppBarBottom(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(6.0),
    child: Visibility(
      visible: context.watch<ApiProvider>().isLoading,
      child: LinearProgressIndicator(
        minHeight: 3.0,
        valueColor: context.watch<ApiProvider>().isError
            ? AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.error)
            : AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
      ),
    ),
  );
}
