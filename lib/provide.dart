import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';

class ApiProvider extends ChangeNotifier {
  final api = Api(2022, 3, dotenv.env['USERNAME']!, dotenv.env['PASSWORD']!);
  var isLoading = false;
  var isError = false;

  void loadSettings() {
    api.loadSettings().then((value) => notifyListeners());
  }

  void clearSettings() {
    api.clearSettings().then((value) => notifyListeners());
  }

  void _onError(Object e) {
    isError = true;
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      isError = false;
      _toggleLoading();
    });
    Fluttertoast.showToast(
      msg: e.toString(),
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 5,
    );
  }

  void _toggleLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void fetchAll() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchLogin();
      await api.fetchSubjects();
      await api.fetchContacts();
      await api.fetchReports();
      await api.fetchQuizzes();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchLogin() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchLogin();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchSubjects() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchSubjects();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchContacts() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchContacts();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailContact(Contact contact) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchDetailContact(contact);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchReports() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchReports();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailReport(Report report) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchDetailReport(report);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void setArchiveReport(String id, bool value) {
    api.reports.where((e) => e.id == id).first.isArchived = value;
    api.saveSettings();
    notifyListeners();
  }

  void fetchQuizzes() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchQuizzes();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailQuiz(Quiz quiz) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await api.fetchDetailQuiz(quiz);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void setArchiveQuiz(String id, bool value) {
    api.quizzes.where((e) => e.id == id).first.isArchived = value;
    api.saveSettings();
    notifyListeners();
  }
}
