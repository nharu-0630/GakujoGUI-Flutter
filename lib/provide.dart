import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';

class Provide extends ChangeNotifier {
  final _api = Api(2022, 2, dotenv.env['USERNAME']!, dotenv.env['PASSWORD']!);

  String get token => _api.token;
  dynamic get settings => _api.settings;

  List<Contact> get contacts => _api.contacts;
  List<Subject> get subjects => _api.subjects;

  void loadSettings() {
    _api.loadSettings().then((value) => notifyListeners());
  }

  void fetchAll() async {
    await _api.login().then((value) => notifyListeners());
    await _api.fetchContacts().then((value) => notifyListeners());
    await _api.fetchSubjects().then((value) => notifyListeners());
  }

  void login() async {
    await _api.login().then((value) => notifyListeners());
  }

  void fetchContacts() async {
    await _api.fetchContacts().then((value) => notifyListeners());
  }

  void fetchSubjects() async {
    await _api.fetchSubjects().then((value) => notifyListeners());
    if (kDebugMode) {
      print(_api.subjects);
    }
  }
}
