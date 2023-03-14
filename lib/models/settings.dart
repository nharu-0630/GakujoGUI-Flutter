import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class Settings {
  @HiveField(0)
  String? username;
  @HiveField(1)
  String? password;
  @HiveField(2)
  int? year;
  @HiveField(3)
  int? semester;
  @HiveField(4)
  String? fullName;
  @HiveField(5)
  String? profileImage;
  @HiveField(6)
  DateTime lastLoginTime = DateTime.fromMicrosecondsSinceEpoch(0);
  @HiveField(7)
  String? accessEnvironmentName;
  @HiveField(8)
  String? accessEnvironmentKey;
  @HiveField(9)
  String? accessEnvironmentValue;

  Settings({
    required this.username,
    required this.password,
    required this.year,
    required this.semester,
    required this.fullName,
    required this.profileImage,
    required this.lastLoginTime,
    required this.accessEnvironmentName,
    required this.accessEnvironmentKey,
    required this.accessEnvironmentValue,
  });

  Settings.init()
      : this(
          username: null,
          password: null,
          year: null,
          semester: null,
          fullName: null,
          profileImage: null,
          lastLoginTime: DateTime.fromMicrosecondsSinceEpoch(0),
          accessEnvironmentName: null,
          accessEnvironmentKey: null,
          accessEnvironmentValue: null,
        );
}

class SettingsBox {
  Future<Box> box = Hive.openBox<Settings>('settings');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Settings>('settings');
    }
  }
}

class SettingsRepository extends ChangeNotifier {
  late SettingsBox _settingsBox;

  SettingsRepository(SettingsBox settingsBox) {
    _settingsBox = settingsBox;
  }

  Future<void> save(Settings settings) async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    await b.put('settings', settings);
    notifyListeners();
  }

  Future<Settings> load() async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    return b.get('settings') ?? Settings.init();
  }

  Future<void> delete() async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    await b.put('settings', Settings.init());
    notifyListeners();
  }

  Future<void> setUsername(String username) async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    Settings settings = b.get('settings') ?? Settings.init();
    settings.username = username;
    await b.put('settings', settings);
    notifyListeners();
  }

  Future<void> setPassword(String password) async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    Settings settings = b.get('settings') ?? Settings.init();
    settings.password = password;
    await b.put('settings', settings);
    notifyListeners();
  }

  Future<void> setYear(int year) async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    Settings settings = b.get('settings') ?? Settings.init();
    settings.year = year;
    await b.put('settings', settings);
    notifyListeners();
  }

  Future<void> setSemester(int semester) async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    Settings settings = b.get('settings') ?? Settings.init();
    settings.semester = semester;
    await b.put('settings', settings);
    notifyListeners();
  }
}
