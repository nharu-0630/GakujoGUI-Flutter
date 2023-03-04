import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/class_link.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/shared_file.dart';

class ApiRepository extends ChangeNotifier {
  final _api = Api();
  String get token => _api.token;

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  bool get isError => _isError;
  bool _isError = false;

  ApiRepository() {
    loadSettings();
  }

  void loadSettings() {
    _api.loadSettings().then((value) => notifyListeners());
  }

  void _onError(Object e) {
    _isError = true;
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      _isError = false;
      _toggleLoading();
    });
    scaffoldMessengerKey.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: e.toString(),
            contentType: ContentType.failure,
            inMaterialBanner: true,
          ),
        ),
      );
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
      await _api.fetchSharedFiles();
      await _api.fetchClassLinks();
      await _api.fetchGrades();
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

  void fetchSharedFiles() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchSharedFiles();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailSharedFile(SharedFile sharedFile) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchDetailSharedFile(sharedFile);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchClassLinks() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchClassLinks();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailClassLink(ClassLink classLink) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchDetailClassLink(classLink);
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchGrades() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchGrades();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }

  void fetchTimetables() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchTimetables();
      _toggleLoading();
    } catch (e) {
      _onError(e);
    }
  }
}
