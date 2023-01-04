import 'package:flutter/material.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/provide.dart';
import 'package:gakujo_task/views/home/home.dart';
import 'package:gakujo_task/views/settings/settings.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        appBar: _buildAppBar(),
        body: const [
          HomeWidget(),
          SettingsWidget(),
        ][_index],
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset('assets/images/avatar.png'),
      ),
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          context.watch<ApiProvider>().api.settings['FullName'] == null
              ? 'Hi!'
              : 'Hi, ${context.watch<ApiProvider>().api.settings['FullName']}!',
        ),
      ),
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Stack(
      children: [
        BottomNavigationBar(
            iconSize: 36.0,
            currentIndex: _index,
            onTap: (value) => setState(() => _index = value),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                  label: 'Home', icon: Icon(Icons.home_rounded)),
              BottomNavigationBarItem(
                label: 'Settings',
                icon: Icon(Icons.settings_rounded),
              ),
            ]),
        Positioned(
          right: 10,
          bottom: 10,
          child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
              if (!snapshot.hasData) {
                return Text(
                  'Client Version: \nAPI Version: ',
                  style: Theme.of(context).textTheme.bodyText1,
                );
              }
              return Text(
                'Client Version: ${snapshot.data!.version}\nAPI Version: ${Api.version}',
                style: Theme.of(context).textTheme.bodyText1,
              );
            },
          ),
        ),
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
