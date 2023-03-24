import 'dart:io';

import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:gakujo_gui/api/api.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/models/class_link.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

class ApiRepository extends ChangeNotifier {
  final _api = Api();
  String get token => _api.token;

  bool get isLoading => _isLoading;
  bool _isLoading = false;
  bool get isError => _isError;
  bool _isError = false;
  double get progress => _progress;
  double _progress = -1;

  ApiRepository();

  void initialize() {
    _api.initialize();
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
    await _api.clearCookies();
  }

  void fetchLogin() async {
    if (isLoading) return;
    _toggleLoading();
    try {
      await _api.fetchLogin();
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
      await _api.fetchSubjects();
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
      await _api.fetchContacts();
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
      await _api.fetchDetailContact(contact);
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
      await _api.fetchReports();
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
      await _api.fetchDetailReport(report);
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
      await _api.fetchQuizzes();
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
      await _api.fetchDetailQuiz(quiz);
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
      await _api.fetchSharedFiles();
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
      await _api.fetchDetailSharedFile(sharedFile);
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
      await _api.fetchClassLinks();
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
      await _api.fetchDetailClassLink(classLink);
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
      await _api.fetchGrades();
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
      await _api.fetchTimetables();
      _toggleLoading();
      _onSuccess('個人時間割の取得');
    } catch (e) {
      _onError(e);
    }
  }
}
