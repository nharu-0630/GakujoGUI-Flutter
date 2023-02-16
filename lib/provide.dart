import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/models/subject.dart';

class ApiProvider extends ChangeNotifier {
  final Api _api = Api();
  String get token => _api.token;
  Settings get settings => _api.settings;
  List<Subject> get subjects => _api.subjects;
  List<Report> get reports => _api.reports;
  List<Quiz> get quizzes => _api.quizzes;

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  bool get isError => _isError;
  bool _isError = false;

  ApiProvider() {
    loadSettings();
  }

  void loadSettings() {
    _api.loadSettings().then((value) => notifyListeners());
  }

  void clearSettings() {
    _api.clearSettings().then((value) => notifyListeners());
  }

  void _onError(Object e) {
    _isError = true;
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      _isError = false;
      _toggleLoading();
    });
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: e.toString(),
        contentType: ContentType.failure,
        inMaterialBanner: true,
      ),
    );
    scaffoldKey.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _toggleLoading() {
    _isLoading = !isLoading;
    notifyListeners();
  }

  void fetchAll() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchLogin();
      await _api.fetchSubjects();
      await _api.fetchContacts();
      await _api.fetchReports();
      await _api.fetchQuizzes();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchTasks() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchReports();
      await _api.fetchQuizzes();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchLogin() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchLogin();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchSubjects() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchSubjects();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchContacts() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchContacts();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailContact(Contact contact) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchDetailContact(contact);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchReports() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchReports();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailReport(Report report) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchDetailReport(report);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void setArchiveReport(String id, bool value) {
    _api.reports.where((e) => e.id == id).first.isArchived = value;
    _api.saveSettings();
    notifyListeners();
  }

  void fetchQuizzes() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchQuizzes();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailQuiz(Quiz quiz) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchDetailQuiz(quiz);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void setArchiveQuiz(String id, bool value) {
    _api.quizzes.where((e) => e.id == id).first.isArchived = value;
    _api.saveSettings();
    notifyListeners();
  }

  void setUserInfo(String username, String password) {
    _api.settings.username = username;
    _api.settings.password = password;
    _api.saveSettings();
  }

  void setSemester(int? year, int? semester) {
    if (year != null) _api.settings.year = year;
    if (semester != null) _api.settings.semester = semester;
    _api.refreshSemester();
  }
}
