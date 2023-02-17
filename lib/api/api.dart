import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:gakujo_task/api/parse.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';

class Api {
  static final Version version = Version(1, 2, 1);

  final Duration _interval = const Duration(milliseconds: 2000);

  Future<Settings>? get _settings =>
      navigatorKey.currentContext?.read<SettingsRepository>().load();

  Future<String?> get _username async => (await _settings)?.username;
  Future<String?> get _password async => (await _settings)?.password;
  Future<int> get _year async => (await _settings)?.year ?? 2022;
  Future<int> get _semester async => (await _settings)?.semester ?? 3;

  Dio _client = Dio();
  CookieJar _cookieJar = CookieJar();

  Api() {
    loadSettings();
  }

  Future<String> get _schoolYear async => (await _year).toString();
  Future<String> get _semesterCode async =>
      ((await _semester) < 2 ? 1 : 2).toString();
  Future<String> get _reportDateStart async =>
      '${await _schoolYear}/${(await _semester) < 2 ? '04' : '10'}/01';

  String _token = '';
  String get token => _token;

  bool _updateToken(dynamic data, {bool required = false}) {
    _token =
        RegExp(r'(?<="org.apache.struts.taglib.html.TOKEN" value=").*(?=")')
                .firstMatch(data.toString())
                ?.group(0) ??
            '';
    if (kDebugMode) {
      print('Token: $_token');
    }
    if (required && _token.isEmpty) {
      throw Exception('Failed to update token.');
    }
    return _token.isNotEmpty;
  }

  Future<void> loadSettings() async {
    final settings = await _settings;
    if (settings?.accessEnvironmentKey != null &&
        settings?.accessEnvironmentValue != null) {
      _cookieJar.saveFromResponse(
        Uri.https('gakujo.shizuoka.ac.jp', '/portal'),
        [
          Cookie(
            settings!.accessEnvironmentKey!,
            settings.accessEnvironmentValue!,
          )
        ],
      );
    }
  }

  Future<void> clearSettings() async =>
      await navigatorKey.currentContext?.watch<SettingsRepository>().delete();

  void _initialize() {
    _client = Dio(BaseOptions(
      headers: {
        'User-Agent': 'Chrome/108.0.5359.124 GakujoTask/$version',
      },
      contentType: Headers.formUrlEncodedContentType,
    ));
    _token = '';
    _cookieJar = CookieJar();
    _client.interceptors.add(CookieManager(_cookieJar));
    _client.interceptors.add(LogInterceptor());
    _client.interceptors.add(RetryInterceptor(
      dio: _client,
      logPrint: print,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 3),
        Duration(seconds: 3),
        Duration(seconds: 3),
      ],
    ));
  }

  Future<void> fetchLogin() async {
    _initialize();
    await loadSettings();

    await Future.delayed(_interval);
    _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/',
      ),
    );

    await Future.delayed(_interval);
    await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/login/preLogin/preLogin',
      ),
      data: 'mistakeChecker=0',
      options: Options(
        followRedirects: false,
        headers: {
          'Origin': 'https://gakujo.shizuoka.ac.jp',
          'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
        },
      ),
    );

    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
      ),
      data: 'selectLocale=ja&mistakeChecker=0&EXCLUDE_SET=',
      options: Options(
        headers: {
          'Origin': 'https://gakujo.shizuoka.ac.jp',
          'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
        },
        followRedirects: false,
        validateStatus: (status) => status! == 302,
      ),
    );

    await Future.delayed(_interval);
    response = await _client.get<dynamic>(
      response.headers.value('location')!,
      options: Options(
        headers: {
          'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
        },
        followRedirects: false,
        validateStatus: (status) => status! == 302 || status == 200,
      ),
    );

    if (response.statusCode == 302) {
      await Future.delayed(_interval);
      await _client.getUri<dynamic>(
        Uri.https(
          'idp.shizuoka.ac.jp',
          '/idp/profile/SAML2/Redirect/SSO',
          {
            'execution': 'e1s1',
          },
        ),
        options: Options(
          followRedirects: false,
          headers: {
            'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
          },
        ),
      );

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'idp.shizuoka.ac.jp',
          '/idp/profile/SAML2/Redirect/SSO',
          {
            'execution': 'e1s1',
          },
        ),
        data:
            'j_username=${await _username}&j_password=${await _password}&_eventId_proceed=',
        options: Options(
          followRedirects: false,
          headers: {
            'Origin': 'https://idp.shizuoka.ac.jp',
            'Referer':
                'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s1',
          },
        ),
      );
    }

    var samlResponse = Uri.decodeFull(
      RegExp(r'(?<=SAMLResponse" value=").*(?=")')
              .firstMatch(response.data.toString())
              ?.group(0) ??
          '',
    );
    var relayState = Uri.decodeFull(
      RegExp(r'(?<=RelayState" value=").*(?=")')
              .firstMatch(response.data.toString())
              ?.group(0) ??
          '',
    ).replaceAll('&#x3a;', ':');

    if (kDebugMode) {
      print('SAMLResponse: ${samlResponse.substring(0, 10)} ...');
      print('RelayState: ${relayState.substring(0, 10)} ...');
    }

    if (samlResponse.isEmpty || relayState.isEmpty) {
      throw Exception('SAMLResponse or RelayState is empty.');
    }

    await Future.delayed(_interval);
    await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/Shibboleth.sso/SAML2/POST',
      ),
      data: {
        'RelayState': relayState,
        'SAMLResponse': samlResponse,
      },
      options: Options(
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
          'Origin': 'https://idp.shizuoka.ac.jp',
          'Referer': 'https://idp.shizuoka.ac.jp/',
        },
        followRedirects: false,
        validateStatus: (status) => status! == 302,
      ),
    );

    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
      ),
      options: Options(
        followRedirects: false,
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
          'Referer': 'https://idp.shizuoka.ac.jp/',
        },
        validateStatus: (status) => status! == 302 || status == 200,
      ),
    );

    if (response.statusCode == 302) {
      await Future.delayed(_interval);
      response = await _client.get<dynamic>(
        response.headers.value('location')!,
      );
    }

    _updateToken(response.data);

    final settings = await _settings;
    if (parse(response.data)
        .querySelectorAll(
            '#container > div > form > div:nth-child(2) > div.access_env > table > tbody > tr > td > input[type=text]')
        .isNotEmpty) {
      var accessEnvName = 'GakujoTask ${(const Uuid()).v4().substring(0, 8)}';

      settings?.accessEnvironmentName = accessEnvName;
      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/accessEnvironmentRegist/goHome/',
        ),
        data:
            'org.apache.struts.taglib.html.TOKEN=$_token&accessEnvName=$accessEnvName&newAccessKey=',
        options: Options(),
      );
    }

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/home/home/initialize',
      ),
      data: 'EXCLUDE_SET=',
    );

    _updateToken(response.data, required: true);

    var name = parse(response.data)
        .querySelector('#header-cog > li > a > span > span')
        ?.text;
    settings?.fullName =
        name?.substring(0, name.indexOf('さん')).replaceAll('　', '');

    if (settings?.profileImage == null) {
      await Future.delayed(_interval);
      response = await _client.getUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/fileDownload/downloadFavoriteImage',
          {
            'org.apache.struts.taglib.html.TOKEN=': _token,
          },
        ),
        options: Options(responseType: ResponseType.bytes),
      );
      settings?.profileImage = base64.encode(response.data);
    }
    settings?.lastLoginTime = DateTime.now();
    List<Cookie> cookies = (await _cookieJar
        .loadForRequest(Uri.https('gakujo.shizuoka.ac.jp', '/portal')));
    if (cookies
        .where(
          (element) => element.name.contains('Access-Environment-Cookie'),
        )
        .isNotEmpty) {
      Cookie cookie = cookies
          .where(
            (element) => element.name.contains('Access-Environment-Cookie'),
          )
          .first;
      settings?.accessEnvironmentKey = cookie.name;
      settings?.accessEnvironmentValue = cookie.value;
    }
    navigatorKey.currentContext?.read<SettingsRepository>().save(settings!);
  }

  Future<void> fetchContacts() async {
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/common/generalPurpose/',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業連絡一覧',
        'menuCode': 'A01',
        'nextPath': '/classcontact/classContactList/initialize'
      },
    );
    _updateToken(response.data, required: true);

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/classcontact/classContactList/selectClassContactList',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'teacherCode': '',
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'searchKeyWord': '',
        'checkSearchKeywordTeacherUserName': 'on',
        'checkSearchKeywordSubjectNam': 'on',
        'checkSearchKeywordTitle': 'on',
        'contactKindCode': '',
        'targetDateStart': '',
        'targetDateEnd': '',
        'reportDateStart': _reportDateStart
      },
    );
    _updateToken(response.data, required: true);

    navigatorKey.currentContext?.watch<ContactRepository>().addAll(
        parse(response.data)
            .querySelectorAll('#tbl_A01_01 > tbody > tr')
            .map(Contact.fromElement)
            .toList());
  }

  Future<Contact> fetchDetailContact(Contact contact,
      {bool bypass = false}) async {
    var index = -1;
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '授業連絡一覧',
          'menuCode': 'A01',
          'nextPath': '/classcontact/classContactList/initialize'
        },
      );
      _updateToken(response.data, required: true);

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classcontact/classContactList/selectClassContactList',
          <String, dynamic>{
            'org.apache.struts.taglib.html.TOKEN': _token,
            'teacherCode': '',
            'schoolYear': await _schoolYear,
            'semesterCode': await _semesterCode,
            'subjectDispCode': '',
            'searchKeyWord': '',
            'checkSearchKeywordTeacherUserName': 'on',
            'checkSearchKeywordSubjectNam': 'on',
            'checkSearchKeywordTitle': 'on',
            'contactKindCode': '',
            'targetDateStart': '',
            'targetDateEnd': '',
            'reportDateStart': _reportDateStart
          },
        ),
      );
      _updateToken(response.data, required: true);

      index = parse(response.data)
          .querySelectorAll('#tbl_A01_01 > tbody > tr')
          .map(Contact.fromElement)
          .toList()
          .indexOf(contact);
      if (index == -1) {
        return contact;
      }
    }

    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classcontact/classContactList/goDetail/$index',
          <String, dynamic>{
            'org.apache.struts.taglib.html.TOKEN': _token,
            'teacherCode': '',
            'schoolYear': await _schoolYear,
            'semesterCode': await _semesterCode,
            'subjectDispCode': '',
            'searchKeyWord': '',
            'checkSearchKeywordTeacherUserName': 'on',
            'checkSearchKeywordSubjectName': 'on',
            'checkSearchKeywordTitle': 'on',
            'contactKindCode': '',
            'targetDateStart': '',
            'targetDateEnd': '',
            'reportDateStart': _reportDateStart,
            'reportDateEnd': '',
            'requireResponse': '',
            'studentCode': '',
            'studentName': '',
            'tbl_A01_01_length': '-1',
          }),
    );
    _updateToken(response.data, required: true);
    var document = parse(response.data);
    if (document.querySelectorAll('table.ttb_entry > tbody > tr > td').length >
        3) {
      contact.fileNames = [];
      var dir = await getApplicationDocumentsDirectory();
      for (var node in document
          .querySelectorAll('table.ttb_entry > tbody > tr > td')[3]
          .querySelectorAll('a')) {
        if (node.attributes['onclick']!.contains('allFileDownload')) {
          continue;
        }
        var prefix = node.attributes['onclick']!
            .trimJsArgs(0)
            .replaceAll('fileDownLoad', '');
        var no = node.attributes['onclick']!.trimJsArgs(1);
        await Future.delayed(_interval);
        var response = await _client.postUri<dynamic>(
          Uri.https(
            'gakujo.shizuoka.ac.jp',
            '/portal/common/fileUploadDownload/fileDownLoad',
          ),
          data: {
            'org.apache.struts.taglib.html.TOKEN': _token,
            'prefix': prefix,
            'no': no,
            'EXCLUDE_SET': '',
            'sequence': '',
            'webspaceTabDisplayFlag': '',
            'screenName': '',
            'fileNameAutonumberFla': '',
            'fileNameDisplayFlag': '',
          },
          options: Options(responseType: ResponseType.bytes),
        );
        var file = File(join(dir.path, basename(node.text.trim())));
        file.writeAsBytes(response.data);
        contact.fileNames?.add(basename(node.text.trim()));
      }
    }

    contact.toDetail(document);
    navigatorKey.currentContext
        ?.watch<ContactRepository>()
        .add(contact, overwrite: true);
    return contact;
  }

  Future<void> fetchSubjects() async {
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/common/generalPurpose/',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業サポート',
        'menuCode': 'A00',
        'nextPath': '/classsupporttop/classSupportTop/initialize'
      },
    );
    _updateToken(response.data, required: true);

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/portaltopcommon/timeTableForTop/searchTimeTable',
          <String, dynamic>{
            'org.apache.struts.taglib.html.TOKEN': _token,
            'schoolYear': await _schoolYear,
            'semesterCode': await _semesterCode,
          }),
    );
    _updateToken(response.data, required: true);

    navigatorKey.currentContext?.watch<SubjectRepository>().deleteAll();
    navigatorKey.currentContext?.watch<SubjectRepository>().addAll(
        parse(response.data)
            .querySelector('#st1')!
            .querySelectorAll('ul')
            .map(Subject.fromElement)
            .toSet()
            .toList());
  }

  Future<void> fetchReports() async {
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/common/generalPurpose/',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業サポート',
        'menuCode': 'A02',
        'nextPath': '/report/student/searchList/initialize'
      },
    );
    _updateToken(response.data, required: true);

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/report/student/searchList/search',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'reportId': '',
        'hidSchoolYear': '',
        'hidSemesterCode': '',
        'hidSubjectCode': '',
        'hidClassCode': '',
        'entranceDiv': '',
        'backPath': '',
        'listSchoolYear': '',
        'listSubjectCode': '',
        'listClassCode': '',
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'operationFormat': ['1', '2'],
        'searchList_length': '-1',
      },
    );
    _updateToken(response.data, required: true);

    navigatorKey.currentContext?.read<ReportRepository>().addAll(
        parse(response.data)
            .querySelectorAll('#searchList > tbody > tr')
            .map(Report.fromElement)
            .toList());
  }

  Future<Report> fetchDetailReport(Report report, {bool bypass = false}) async {
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '授業サポート',
          'menuCode': 'A02',
          'nextPath': '/report/student/searchList/initialize'
        },
      );
      _updateToken(response.data, required: true);

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/report/student/searchList/search',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'reportId': '',
          'hidSchoolYear': '',
          'hidSemesterCode': '',
          'hidSubjectCode': '',
          'hidClassCode': '',
          'entranceDiv': '',
          'backPath': '',
          'listSchoolYear': '',
          'listSubjectCode': '',
          'listClassCode': '',
          'schoolYear': await _schoolYear,
          'semesterCode': await _semesterCode,
          'subjectDispCode': '',
          'operationFormat': ['1', '2'],
          'searchList_length': '-1',
        },
      );
      _updateToken(response.data, required: true);

      if (parse(response.data)
          .querySelectorAll('#searchList > tbody > tr')
          .map(Report.fromElement)
          .where((e) => e == report)
          .isEmpty) {
        return report;
      }
    }
    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/report/student/searchList/forwardSubmitRef',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'reportId': report.id,
        'hidSchoolYear': '',
        'hidSemesterCode': '',
        'hidSubjectCode': '',
        'hidClassCode': '',
        'entranceDiv': '',
        'backPath': '',
        'listSchoolYear': await _schoolYear,
        'listSubjectCode': report.subjectCode,
        'listClassCode': report.classCode,
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'operationFormat': ['1', '2'],
        'searchList_length': '-1',
      },
    );
    _updateToken(response.data, required: true);
    var document = parse(response.data);
    report.fileNames = [];
    var dir = await getApplicationDocumentsDirectory();
    for (var node in document
        .querySelector('#area > table > tbody > tr:nth-child(4) > td')!
        .querySelectorAll('a')) {
      if (node.attributes['onclick']!.contains('fileAllDownload')) {
        continue;
      }
      var selectedKey = node.attributes['onclick']!
          .trimJsArgs(0)
          .replaceAll('fileDownload', '');
      var prefix = node.attributes['onclick']!.trimJsArgs(1);
      await Future.delayed(_interval);
      var response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classsupport/fileDownload/temporaryFileDownload',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'selectedKey': selectedKey,
          'prefix': prefix,
          'EXCLUDE_SET': '',
        },
        options: Options(responseType: ResponseType.bytes),
      );
      var file = File(join(dir.path, basename(node.text.trim())));
      file.writeAsBytes(response.data);
      report.fileNames?.add(basename(node.text.trim()));
    }

    report.toDetail(document);
    navigatorKey.currentContext
        ?.read<ReportRepository>()
        .add(report, overwrite: true);
    return report;
  }

  Future<void> fetchQuizzes() async {
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/common/generalPurpose/',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '小テスト一覧',
        'menuCode': 'A03',
        'nextPath': '/test/student/searchList/initialize'
      },
    );
    _updateToken(response.data, required: true);

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/test/student/searchList/search',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'testId': '',
        'hidSchoolYear': '',
        'hidSemesterCode': '',
        'hidSubjectCode': '',
        'hidClassCode': '',
        'entranceDiv': '',
        'backPath': '',
        'listSchoolYear': '',
        'listSubjectCode': '',
        'listClassCode': '',
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'operationFormat': ['1', '2'],
        'searchList_length': '-1',
      },
    );
    _updateToken(response.data, required: true);

    navigatorKey.currentContext?.read<QuizRepository>().addAll(
        parse(response.data)
            .querySelectorAll('#searchList > tbody > tr')
            .map(Quiz.fromElement)
            .toList());
  }

  Future<Quiz> fetchDetailQuiz(Quiz quiz, {bool bypass = false}) async {
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '小テスト一覧',
          'menuCode': 'A03',
          'nextPath': '/test/student/searchList/initialize'
        },
      );
      _updateToken(response.data, required: true);

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/test/student/searchList/search',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'testId': '',
          'hidSchoolYear': '',
          'hidSemesterCode': '',
          'hidSubjectCode': '',
          'hidClassCode': '',
          'entranceDiv': '',
          'backPath': '',
          'listSchoolYear': '',
          'listSubjectCode': '',
          'listClassCode': '',
          'schoolYear': await _schoolYear,
          'semesterCode': await _semesterCode,
          'subjectDispCode': '',
          'operationFormat': ['1', '2'],
          'searchList_length': '-1',
        },
      );
      _updateToken(response.data, required: true);

      if (parse(response.data)
          .querySelectorAll('#searchList > tbody > tr')
          .map(Quiz.fromElement)
          .where((e) => e == quiz)
          .isEmpty) {
        return quiz;
      }
    }
    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https('gakujo.shizuoka.ac.jp',
          '/portal/test/student/searchList/forwardSubmitRef', <String, dynamic>{
        'org.apache.struts.taglib.html.TOKEN': _token,
        'testId': quiz.id,
        'hidSchoolYear': '',
        'hidSemesterCode': '',
        'hidSubjectCode': '',
        'hidClassCode': '',
        'entranceDiv': '',
        'backPath': '',
        'listSchoolYear': await _schoolYear,
        'listSubjectCode': quiz.subjectCode,
        'listClassCode': quiz.classCode,
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'operationFormat': ['1', '2'],
        'searchList_length': '-1',
      }),
    );
    _updateToken(response.data, required: true);
    var document = parse(response.data);
    quiz.fileNames = [];
    var dir = await getApplicationDocumentsDirectory();
    for (var node in document
        .querySelector('#area > table > tbody > tr:nth-child(5) > td')!
        .querySelectorAll('a')) {
      if (node.attributes['onclick']!.contains('fileAllDownload')) {
        continue;
      }
      var selectedKey = node.attributes['onclick']!
          .trimJsArgs(0)
          .replaceAll('fileDownload', '');
      var prefix = node.attributes['onclick']!.trimJsArgs(1);
      await Future.delayed(_interval);
      var response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classsupport/fileDownload/temporaryFileDownload',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'selectedKey': selectedKey,
          'prefix': prefix,
          'EXCLUDE_SET': '',
        },
        options: Options(responseType: ResponseType.bytes),
      );
      var file = File(join(dir.path, basename(node.text.trim())));
      file.writeAsBytes(response.data);
      quiz.fileNames?.add(basename(node.text.trim()));
    }

    quiz.toDetail(document);
    navigatorKey.currentContext
        ?.read<QuizRepository>()
        .add(quiz, overwrite: true);
    return quiz;
  }
}
