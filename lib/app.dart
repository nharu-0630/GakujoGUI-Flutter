import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
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
    var settings = context.watch<ApiProvider>().settings;
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: settings.profileImage == null
            ? const Icon(Icons.person_rounded, size: 36.0)
            : CircleAvatar(
                backgroundImage: CachedMemoryImageProvider('ProfileImage',
                    base64: settings.profileImage),
              ),
      ),
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          settings.fullName == null ? 'Hi!' : 'Hi, ${settings.fullName}!',
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
          ],
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
