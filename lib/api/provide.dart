import 'dart:io';

import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:gakujo_gui/api/gakujo_api.dart';
import 'package:gakujo_gui/api/syllabus_api.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/models/class_link.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/models/syllabus.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:gakujo_gui/models/syllabus_search.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class ApiRepository extends ChangeNotifier {
  final _gakujoApi = GakujoApi();
  String get token => _gakujoApi.token;

  final _syllabusApi = SyllabusApi();

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  bool get isError => _isError;
  bool _isError = false;
  double get progress => _progress;
  double _progress = -1;

  ApiRepository();

  void initialize() {
    _gakujoApi.initialize();
  }

  void setProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  void _onSuccess(String content) {
    showFlash(
      context: App.navigatorKey.currentState!.overlay!.context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return buildInfoFlashBar(context, controller,
            content: '$contentに成功しました');
      },
    );
  }

  void _onError(Object e) {
    _isError = true;
    if (Platform.isWindows) {
      WindowsTaskbar.setFlashTaskbarAppIcon(
        mode: TaskbarFlashMode.all,
        timeout: const Duration(milliseconds: 500),
      );
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.error);
    }
    notifyListeners();
    Future<void>.delayed(const Duration(seconds: 2), () {
      _isError = false;
      if (Platform.isWindows) {
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }
      _toggleLoading();
    });

    showFlash(
      context: App.navigatorKey.currentState!.overlay!.context,
      builder: (context, controller) {
        return buildErrorFlashBar(context, controller, e);
      },
    );
  }

  void _toggleLoading() {
    _isLoading = !isLoading;
    _progress = -1;
    if (Platform.isWindows) {
      if (isLoading) {
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
      } else {
        WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
      }
    }
    notifyListeners();
  }

  void clearCookies() async {
    await _gakujoApi.clearCookies();
  }

  void fetchLogin() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchLogin();
      _toggleLoading();
      _onSuccess('ログイン');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchSubjects() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchSubjects();
      _toggleLoading();
      _onSuccess('授業科目一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchContacts() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchContacts();
      _toggleLoading();
      _onSuccess('授業連絡一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailContact(Contact contact) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchDetailContact(contact);
      _toggleLoading();
      _onSuccess('授業連絡詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchReports() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchReports();
      _toggleLoading();
      _onSuccess('レポート一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailReport(Report report) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchDetailReport(report);
      _toggleLoading();
      _onSuccess('レポート詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchQuizzes() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchQuizzes();
      _toggleLoading();
      _onSuccess('小テスト一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailQuiz(Quiz quiz) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchDetailQuiz(quiz);
      _toggleLoading();
      _onSuccess('小テスト詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchSharedFiles() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchSharedFiles();
      _toggleLoading();
      _onSuccess('授業共有ファイル一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailSharedFile(SharedFile sharedFile) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchDetailSharedFile(sharedFile);
      _toggleLoading();
      _onSuccess('授業共有ファイル詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchClassLinks() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchClassLinks();
      _toggleLoading();
      _onSuccess('授業リンク一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailClassLink(ClassLink classLink) async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchDetailClassLink(classLink);
      _toggleLoading();
      _onSuccess('授業リンク詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchGrades() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchGrades();
      _toggleLoading();
      _onSuccess('成績情報の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchTimetables() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _gakujoApi.fetchTimetables();
      _toggleLoading();
      _onSuccess('個人時間割の取得');
    } catch (e) {
      _onError(e);
    }
  }

  Future<SyllabusSearch?> fetchSyllabusSearch(String syllabusTitleID) async {
    try {
      var result = await _syllabusApi.fetchSyllabusSearch(syllabusTitleID);
      _onSuccess('シラバス検索条件の取得');
      return result;
    } catch (e) {
      _onError(e);
    }
    return null;
  }

  Future<List<SyllabusResult>> fetchSyllabusResult({
    required int academicYear,
    required String syllabusTitleID,
    required String indexID,
    required String targetGrade,
    required String semester,
    required String week,
    required String hour,
    required String kamokuName,
    required String editorName,
    required String freeWord,
  }) async {
    try {
      var result = await _syllabusApi.fetchSyllabusResult(
        academicYear: academicYear != -1 ? academicYear.toString() : '',
        syllabusTitleID: syllabusTitleID,
        indexID: indexID,
        targetGrade: targetGrade,
        semester: semester,
        week: week,
        hour: hour,
        kamokuName: kamokuName,
        editorName: editorName,
        freeWord: freeWord,
      );
      _onSuccess('シラバス検索結果の取得');
      return result;
    } catch (e) {
      _onError(e);
    }
    return [];
  }

  Future<Syllabus?> fetchSyllabusDetail(String subjectId) async {
    try {
      var result = await _syllabusApi.fetchSyllabus(subjectId);
      _onSuccess('シラバス詳細の取得');
      return result;
    } catch (e) {
      _onError(e);
    }
    return null;
  }
}
