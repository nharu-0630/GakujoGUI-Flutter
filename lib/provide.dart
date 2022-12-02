import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gakujo_task/api/api.dart';

class Provide extends ChangeNotifier {
  final api = Api(2022, 2, dotenv.env['USERNAME']!, dotenv.env['PASSWORD']!);

  void loadSettings() {
    api.loadSettings().then((value) => notifyListeners());
  }

  void login() async {
    try {
      await api.fetchLogin().then((value) => notifyListeners());
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    }
  }

  void fetchSubjects() async {
    try {
      await api.fetchSubjects().then((value) => notifyListeners());
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    }
  }

  void fetchContacts() async {
    try {
      await api.fetchContacts().then((value) => notifyListeners());
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    }
  }

  void fetchReports() async {
    try {
      await api.fetchReports().then((value) => notifyListeners());
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    }
  }

  void fetchQuizzes() async {
    try {
      await api.fetchQuizzes().then((value) => notifyListeners());
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    }
  }

  void refresh() {
    notifyListeners();
  }
}
