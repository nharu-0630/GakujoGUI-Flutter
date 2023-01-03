import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gakujo_task/api/api.dart';

class ApiProvider extends ChangeNotifier {
  final api = Api(2022, 3, dotenv.env['USERNAME']!, dotenv.env['PASSWORD']!);

  void loadSettings() {
    api.loadSettings().then((value) => notifyListeners());
  }

  void clearSettings() {
    api.clearSettings().then((value) => notifyListeners());
  }

  void fetchLogin() async {
    try {
      await api.fetchLogin().then((_) => notifyListeners());
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
      await api.fetchSubjects().then((_) => notifyListeners());
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
      await api.fetchContacts().then((_) => notifyListeners());
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
      await api.fetchReports().then((_) => notifyListeners());
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
}
