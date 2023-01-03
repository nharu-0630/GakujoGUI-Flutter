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
    context.read<ApiProvider>().loadSettings();
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Murecho',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Murecho',
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
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 36.0,
              width: 36.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset('assets/images/avatar.png'),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                context.watch<ApiProvider>().api.settings['FullName'] == null
                    ? 'Hi!'
                    : 'Hi, ${context.watch<ApiProvider>().api.settings['FullName']}!',
                style: Theme.of(context).textTheme.headlineSmall,
              )),
        ],
      ),
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
