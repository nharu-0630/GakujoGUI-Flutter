import 'package:gakujo_task/api/parse.dart';

class Settings {
  String? username;
  String? password;
  int? year;
  int? semester;
  String? fullName;
  String? profileImage;
  DateTime lastLoginTime = DateTime.fromMicrosecondsSinceEpoch(0);
  String? accessEnvironmentName;
  String? accessEnvironmentKey;
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

  static Map<String, dynamic> toMap(Settings settings) => <String, dynamic>{
        'username': settings.username,
        'password': settings.password,
        'year': settings.year,
        'semester': settings.semester,
        'fullName': settings.fullName,
        'profileImage': settings.profileImage,
        'lastLoginTime': settings.lastLoginTime.toIso8601String(),
        'accessEnvironmentName': settings.accessEnvironmentName,
        'accessEnvironmentKey': settings.accessEnvironmentKey,
        'accessEnvironmentValue': settings.accessEnvironmentValue,
      };

  factory Settings.fromJson(dynamic json) {
    json = json as Map<String, dynamic>;
    return Settings(
      json['username'] as String?,
      json['password'] as String?,
      json['year'] as int?,
      json['semester'] as int?,
      json['fullName'] as String?,
      json['profileImage'] as String?,
      (json['lastLoginTime'] as String).parseDateTime(),
      json['accessEnvironmentName'] as String?,
      json['accessEnvironmentKey'] as String?,
      json['accessEnvironmentValue'] as String?,
    );
  }
}
