import 'dart:io';

import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:gakujo_gui/api/gakujo_api.dart';
import 'package:gakujo_gui/api/syllabus_api.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/models/class_link.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/questionnaire.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/settings.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/models/syllabus_detail.dart';
import 'package:gakujo_gui/models/syllabus_parameters.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class ApiRepository extends ChangeNotifier {
  late GakujoApi _gakujoApi;
  String get token => _gakujoApi.token;

  final _syllabusApi = SyllabusApi();

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  bool get isError => _isError;
  bool _isError = false;
  double get progress => _progress;
  double _progress = -1;

  void initialize() {
    var settings = Settings.init();
    _gakujoApi = GakujoApi(
      username: settings.username ?? '',
      password: settings.password ?? '',
      secret: '',
      year: settings.year ?? 2023,
      semester: settings.semester ?? 3,
    );
    _gakujoApi.initialize(null);
  }

  void setProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  void _onSuccess(String content) {
    showFlash(
      context: App.navigatorKey.currentState!.overlay!.context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) =>
          buildInfoFlashBar(context, controller, content: '$contentに成功しました'),
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
      _setStatus(false);
    });
    showFlash(
      context: App.navigatorKey.currentState!.overlay!.context,
      builder: (context, controller) =>
          buildErrorFlashBar(context, controller, e),
    );
  }

  void _setStatus(bool value) {
    _isLoading = value;
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
    _setStatus(true);
    // try {
    await _gakujoApi.fetchLogin();
    _setStatus(false);
    _onSuccess('ログイン');
    // } catch (e) {
    //   _onError(e);
    // }
  }

  void fetchSubjects() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchSubjects();
      _setStatus(false);
      _onSuccess('授業科目一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchContacts() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchContacts();
      _setStatus(false);
      _onSuccess('授業連絡一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailContact(Contact contact) async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchDetailContact(contact);
      _setStatus(false);
      _onSuccess('授業連絡詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchReports() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchReports();
      _setStatus(false);
      _onSuccess('レポート一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailReport(Report report) async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchDetailReport(report);
      _setStatus(false);
      _onSuccess('レポート詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchQuizzes() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchQuizzes();
      _setStatus(false);
      _onSuccess('小テスト一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailQuiz(Quiz quiz) async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchDetailQuiz(quiz);
      _setStatus(false);
      _onSuccess('小テスト詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchSharedFiles() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchSharedFiles();
      _setStatus(false);
      _onSuccess('授業共有ファイル一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailSharedFile(SharedFile sharedFile) async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchDetailSharedFile(sharedFile);
      _setStatus(false);
      _onSuccess('授業共有ファイル詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchClassLinks() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchClassLinks();
      _setStatus(false);
      _onSuccess('授業リンク一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailClassLink(ClassLink classLink) async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchDetailClassLink(classLink);
      _setStatus(false);
      _onSuccess('授業リンク詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchQuestionnaires() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchQuestionnaires();
      _setStatus(false);
      _onSuccess('授業アンケート一覧の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchDetailQuestionnaire(Questionnaire questionnaire) async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchDetailQuestionnaire(questionnaire);
      _setStatus(false);
      _onSuccess('授業アンケート詳細の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchGrades() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchGrades();
      _setStatus(false);
      _onSuccess('成績情報の取得');
    } catch (e) {
      _onError(e);
    }
  }

  void fetchTimetables() async {
    if (isLoading) return;
    _setStatus(true);
    try {
      await _gakujoApi.fetchTimetables();
      _setStatus(false);
      _onSuccess('個人時間割の取得');
    } catch (e) {
      _onError(e);
    }
  }

  Future<SyllabusParameters?> fetchSyllabusParameters(
      String syllabusTitleID) async {
    try {
      var result = await _syllabusApi.fetchSyllabusParameters(syllabusTitleID);
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

  Future<SyllabusDetail?> fetchSyllabusDetail(SyllabusResult query) async {
    try {
      var result = await _syllabusApi.fetchSyllabusDetail(query);
      _onSuccess('シラバス詳細の取得');
      return result;
    } catch (e) {
      _onError(e);
    }
    return null;
  }
}
