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

  Settings(
    this.username,
    this.password,
    this.year,
    this.semester,
    this.fullName,
    this.profileImage,
    this.lastLoginTime,
    this.accessEnvironmentName,
    this.accessEnvironmentKey,
    this.accessEnvironmentValue,
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

class SettingsRepository {
  late SettingsBox _settingsBox;

  SettingsRepository(SettingsBox settingsBox) {
    _settingsBox = settingsBox;
  }

  Future<void> save(Settings settings) async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    await b.put('settings', settings);
  }

  Future<Settings> load() async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    return b.get('settings') ??
        Settings(null, null, null, null, null, null,
            DateTime.fromMicrosecondsSinceEpoch(0), null, null, null);
  }

  Future<void> delete() async {
    await _settingsBox.open();
    Box b = await _settingsBox.box;
    await b.delete('settings');
  }
}
