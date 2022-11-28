import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';

class Api {
  static final Version version = Version(1, 0, 1);

  final Duration _interval = const Duration(milliseconds: 2000);

  final int year;
  final int semester;
  final String username;
  final String password;

  Dio _client = Dio();
  CookieJar _cookieJar = CookieJar();

  Api(this.year, this.semester, this.username, this.password);

  String get schoolYear => year.toString();
  String get semesterCode => (semester < 2 ? 1 : 2).toString();
  String get reportDateStart => '$schoolYear/${semester < 2 ? '04' : '10'}/01';
  String get reportDateEnd => '$schoolYear/${semester < 2 ? '09' : '03'}/01';
  String get suffix => '_${year}_$semesterCode';

  String _token = '';
  String get token => _token;

  dynamic _settings = {};
  dynamic get settings => _settings;

  final List<Contact> _contacts = [];
  List<Contact> get contacts => _contacts;

  final List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  bool _updateToken(dynamic data) {
    _token =
        RegExp(r'(?<="org.apache.struts.taglib.html.TOKEN" value=").*(?=")')
                .firstMatch(data.toString())
                ?.group(0) ??
            _token;
    if (kDebugMode) {
      print('Token: $_token');
    }
    return _token != '';
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('Settings') == null) {
      return;
    }
    _settings = json.decode(prefs.getString('Settings')!);

    if (_settings['AccessEnvironmentKey'] != null &&
        _settings['AccessEnvironmentValue'] != null) {
      _cookieJar.saveFromResponse(
          Uri.https('gakujo.shizuoka.ac.jp', '/portal'), [
        Cookie(_settings['AccessEnvironmentKey'],
            _settings['AccessEnvironmentValue'])
      ]);
    }
    if (prefs.getString('Subjects$suffix') != null) {
      _subjects.clear();
      _subjects.addAll(Subject.decode(prefs.getString('Subjects$suffix')!));
    }
    if (prefs.getString('Contacts$suffix') != null) {
      _contacts.clear();
      _contacts.addAll(Contact.decode(prefs.getString('Contacts$suffix')!));
    }
  }

  Future<void> saveSettings() async {
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
      _settings['AccessEnvironmentKey'] = cookie.name;
      _settings['AccessEnvironmentValue'] = cookie.value;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Settings', json.encode(_settings));
    await prefs.setString('Subjects$suffix', Subject.encode(_subjects));
    await prefs.setString('Contacts$suffix', Contact.encode(_contacts));
  }

  void _initialize() {
    _client = Dio(BaseOptions(
      headers: {
        'User-Agent': 'Chrome/105.0.5195.127 GakujoTask/$version',
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

  Future<bool> login() async {
    _initialize();
    await loadSettings();

    await _client.getUri<dynamic>(
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
    await Future.delayed(_interval);

    if (response.statusCode == 302) {
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
        data: 'j_username=$username&j_password=$password&_eventId_proceed=',
        options: Options(
          followRedirects: false,
          headers: {
            'Origin': 'https://idp.shizuoka.ac.jp',
            'Referer':
                'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s1',
          },
        ),
      );
      await Future.delayed(_interval);
    }

    final samlResponse = Uri.decodeFull(
      RegExp(r'(?<=SAMLResponse" value=").*(?=")')
              .firstMatch(response.data.toString())
              ?.group(0) ??
          '',
    );
    final relayState = Uri.decodeFull(
      RegExp(r'(?<=RelayState" value=").*(?=")')
              .firstMatch(response.data.toString())
              ?.group(0) ??
          '',
    ).replaceAll('&#x3a;', ':');

    if (kDebugMode) {
      print('SAMLResponse: ${samlResponse.substring(0, 10)} ...');
      print('RelayState: ${relayState.substring(0, 10)} ...');
    }

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
    await Future.delayed(_interval);

    if (response.statusCode == 302) {
      response = await _client.get<dynamic>(
        response.headers.value('location')!,
      );
      await Future.delayed(_interval);
    }

    _updateToken(response.data);
    var document = parse(response.data);

    if (document
        .querySelectorAll(
            '#container > div > form > div:nth-child(2) > div.access_env > table > tbody > tr > td > input[type=text]')
        .isNotEmpty) {
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/accessEnvironmentRegist/goHome/',
        ),
        data:
            'org.apache.struts.taglib.html.TOKEN=$_token&accessEnvName=GakujoTask ${(const Uuid()).v4().substring(0, 8)}&newAccessKey=',
        options: Options(),
      );
      await Future.delayed(_interval);
    }

    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/home/home/initialize',
      ),
      data: 'EXCLUDE_SET=',
    );
    document = parse(response.data);
    await Future.delayed(_interval);

    var name =
        document.querySelector('#header-cog > li > a > span > span')?.text;
    _settings['FullName'] =
        name?.substring(0, name.indexOf('さん')).replaceAll('　', '');

    _updateToken(response.data);
    saveSettings();
    return true;
  }

  Future<List<Contact>> fetchContacts() async {
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
    _updateToken(response.data);
    await Future.delayed(_interval);

    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/classcontact/classContactList/selectClassContactList',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'teacherCode': '',
        'schoolYear': schoolYear,
        'semesterCode': semesterCode,
        'subjectDispCode': '',
        'searchKeyWord': '',
        'checkSearchKeywordTeacherUserName': 'on',
        'checkSearchKeywordSubjectNam': 'on',
        'checkSearchKeywordTitle': 'on',
        'contactKindCode': '',
        'targetDateStart': '',
        'targetDateEnd': '',
        'reportDateStart': reportDateStart
      },
    );
    _updateToken(response.data);
    await Future.delayed(_interval);

    final document = parse(response.data);

    for (var element in document
        .querySelectorAll('#tbl_A01_01 > tbody > tr')
        .map(Contact.fromElement)
        .toList()) {
      if (!_contacts.contains(element)) _contacts.add(element);
    }
    return contacts;
  }

  Future<Contact> fetchDetailContact(Contact contact,
      {bool bypass = false}) async {
    Document document;
    var index = -1;
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https('gakujo.shizuoka.ac.jp',
            '/portal/common/generalPurpose/', <String, dynamic>{
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '授業連絡一覧',
          'menuCode': 'A01',
          'nextPath': '/classcontact/classContactList/initialize'
        }),
      );
      _updateToken(response.data);
      await Future.delayed(_interval);

      response = await _client.postUri<dynamic>(
        Uri.https(
            'gakujo.shizuoka.ac.jp',
            '/portal/classcontact/classContactList/selectClassContactList',
            <String, dynamic>{
              'org.apache.struts.taglib.html.TOKEN': _token,
              'teacherCode': '',
              'schoolYear': schoolYear,
              'semesterCode': semesterCode,
              'subjectDispCode': '',
              'searchKeyWord': '',
              'checkSearchKeywordTeacherUserName': 'on',
              'checkSearchKeywordSubjectNam': 'on',
              'checkSearchKeywordTitle': 'on',
              'contactKindCode': '',
              'targetDateStart': '',
              'targetDateEnd': '',
              'reportDateStart': reportDateStart
            }),
      );
      _updateToken(response.data);
      await Future.delayed(_interval);

      final document = parse(response.data);
      index = document
          .querySelectorAll('#tbl_A01_01 > tbody > tr')
          .map(Contact.fromElement)
          .toList()
          .indexOf(contact);
      if (index == -1) {
        return contact;
      }
    }
    final response = await _client.postUri<dynamic>(
      Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classcontact/classContactList/goDetail/$index',
          <String, dynamic>{
            'org.apache.struts.taglib.html.TOKEN': _token,
            'teacherCode': '',
            'schoolYear': schoolYear,
            'semesterCode': semesterCode,
            'subjectDispCode': '',
            'searchKeyWord': '',
            'checkSearchKeywordTeacherUserName': 'on',
            'checkSearchKeywordSubjectName': 'on',
            'checkSearchKeywordTitle': 'on',
            'contactKindCode': '',
            'targetDateStart': '',
            'targetDateEnd': '',
            'reportDateStart': reportDateStart,
            'reportDateEnd': '',
            'requireResponse': '',
            'studentCode': '',
            'studentName': '',
            'tbl_A01_01_length': '-1',
          }),
    );
    _updateToken(response.data);
    await Future.delayed(_interval);

    document = parse(response.data);
    _contacts[index].toDetail(document);
    return contacts[index];
  }

  Future<List<Subject>> fetchSubjects() async {
    var response = await _client.postUri<dynamic>(
      Uri.https('gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/', <String, dynamic>{
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業サポート',
        'menuCode': 'A00',
        'nextPath': '/classsupporttop/classSupportTop/initialize'
      }),
    );
    _updateToken(response.data);
    await Future.delayed(_interval);

    response = await _client.postUri<dynamic>(
      Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/portaltopcommon/timeTableForTop/searchTimeTable',
          <String, dynamic>{
            'org.apache.struts.taglib.html.TOKEN': _token,
            'schoolYear': schoolYear,
            'semesterCode': semesterCode,
          }),
    );
    _updateToken(response.data);
    await Future.delayed(_interval);

    final document = parse(response.data);

    _subjects.clear();
    _subjects.addAll(document
        .querySelector('#st1')!
        .querySelectorAll('ul')
        .map(Subject.fromElement));
    saveSettings();
    return _subjects;
  }

  // Future<List<Report>> getReports(List<Report> reports) async {
  //   await Wakelock.enable();
  //   var response = await _client.postUri<dynamic>(
  //     Uri.https('gakujo.shizuoka.ac.jp',
  //         '/portal/common/generalPurpose/', <String, dynamic>{
  //       'org.apache.struts.taglib.html.TOKEN': _token,
  //       'headTitle': '授業サポート',
  //       'menuCode': 'A02',
  //       'nextPath': '/report/student/searchList/initialize'
  //     }),
  //   );
  //   _updateToken(response.data);
  //   response = await _client.postUri<dynamic>(
  //     Uri.https('gakujo.shizuoka.ac.jp',
  //         '/portal/report/student/searchList/search', <String, dynamic>{
  //       'org.apache.struts.taglib.html.TOKEN': _token,
  //       'reportId': '',
  //       'hidSchoolYear': '',
  //       'hidSemesterCode': '',
  //       'hidSubjectCode': '',
  //       'hidClassCode': '',
  //       'entranceDiv': '',
  //       'backPath': '',
  //       'listSchoolYear': '',
  //       'listSubjectCode': '',
  //       'listClassCode': '',
  //       'schoolYear': schoolYear,
  //       'semesterCode': semesterCode,
  //       'subjectDispCode': '',
  //       'operationFormat': ['1', '2'],
  //       'searchList_length': '-1',
  //       '_searchConditionDisp.accordionSearchCondition': 'true',
  //       '_screenIdentifier': 'SC_A02_01_G',
  //       '_screenInfoDisp': '',
  //       '_scrollTop': '0'
  //     }),
  //   );
  //   _updateToken(response.data);
  //   final document = parse(response.data);
  //   for (final report in document
  //       .querySelectorAll('#searchList > tbody > tr')
  //       .map(Report.fromElement)) {
  //     if (!reports.contains(report)) {
  //       reports.add(report);
  //     } else {
  //       reports.where((x) => x == report).forEach((x) => x.toRefresh(report));
  //     }
  //   }
  //   await Wakelock.disable();
  //   return reports;
  // }

  // Future<Report> getReport(Report report, {bool bypass = false}) async {
  //   await Wakelock.enable();
  //   Document document;
  //   if (!bypass) {
  //     var response = await _client.postUri<dynamic>(
  //       Uri.https('gakujo.shizuoka.ac.jp',
  //           '/portal/common/generalPurpose/', <String, dynamic>{
  //         'org.apache.struts.taglib.html.TOKEN': _token,
  //         'headTitle': '授業サポート',
  //         'menuCode': 'A02',
  //         'nextPath': '/report/student/searchList/initialize'
  //       }),
  //     );
  //     _updateToken(response.data);
  //     response = await _client.postUri<dynamic>(
  //       Uri.https('gakujo.shizuoka.ac.jp',
  //           '/portal/report/student/searchList/search', <String, dynamic>{
  //         'org.apache.struts.taglib.html.TOKEN': _token,
  //         'reportId': '',
  //         'hidSchoolYear': '',
  //         'hidSemesterCode': '',
  //         'hidSubjectCode': '',
  //         'hidClassCode': '',
  //         'entranceDiv': '',
  //         'backPath': '',
  //         'listSchoolYear': '',
  //         'listSubjectCode': '',
  //         'listClassCode': '',
  //         'schoolYear': schoolYear,
  //         'semesterCode': semesterCode,
  //         'subjectDispCode': '',
  //         'operationFormat': ['1', '2'],
  //         'searchList_length': '-1',
  //         '_searchConditionDisp.accordionSearchCondition': 'true',
  //         '_screenIdentifier': 'SC_A02_01_G',
  //         '_screenInfoDisp': '',
  //         '_scrollTop': '0'
  //       }),
  //     );
  //     _updateToken(response.data);
  //     document = parse(response.data);
  //     if (document
  //         .querySelectorAll('#searchList > tbody > tr')
  //         .map(Report.fromElement)
  //         .where((x) => x == report)
  //         .isEmpty) {
  //       await Wakelock.disable();
  //       return report;
  //     }
  //   }
  //   final response = await _client.postUri<dynamic>(
  //     Uri.https(
  //         'gakujo.shizuoka.ac.jp',
  //         '/portal/report/student/searchList/forwardSubmitRef',
  //         <String, dynamic>{
  //           'org.apache.struts.taglib.html.TOKEN': _token,
  //           'reportId': report.id,
  //           'hidSchoolYear': '',
  //           'hidSemesterCode': '',
  //           'hidSubjectCode': '',
  //           'hidClassCode': '',
  //           'entranceDiv': '',
  //           'backPath': '',
  //           'listSchoolYear': schoolYear,
  //           'listSubjectCode': report.subjectCode,
  //           'listClassCode': report.classCode,
  //           'schoolYear': schoolYear,
  //           'semesterCode': semesterCode,
  //           'subjectDispCode': '',
  //           'operationFormat': ['1', '2'],
  //           'searchList_length': '-1',
  //           '_searchConditionDisp.accordionSearchCondition': 'true',
  //           '_screenIdentifier': 'SC_A02_01_G',
  //           '_screenInfoDisp': '',
  //           '_scrollTop': '0'
  //         }),
  //   );
  //   _updateToken(response.data);
  //   document = parse(response.data);
  //   report.toDetail(document);
  //   await Wakelock.disable();
  //   return report;
  // }

  // Future<List<Quiz>> getQuizzes(List<Quiz> quizzes) async {
  //   await Wakelock.enable();
  //   var response = await _client.postUri<dynamic>(
  //     Uri.https('gakujo.shizuoka.ac.jp',
  //         '/portal/common/generalPurpose/', <String, dynamic>{
  //       'org.apache.struts.taglib.html.TOKEN': _token,
  //       'headTitle': '小テスト一覧',
  //       'menuCode': 'A03',
  //       'nextPath': '/test/student/searchList/initialize'
  //     }),
  //   );
  //   _updateToken(response.data);
  //   response = await _client.postUri<dynamic>(
  //     Uri.https('gakujo.shizuoka.ac.jp',
  //         '/portal/test/student/searchList/search', <String, dynamic>{
  //       'org.apache.struts.taglib.html.TOKEN': _token,
  //       'testId': '',
  //       'hidSchoolYear': '',
  //       'hidSemesterCode': '',
  //       'hidSubjectCode': '',
  //       'hidClassCode': '',
  //       'entranceDiv': '',
  //       'backPath': '',
  //       'listSchoolYear': '',
  //       'listSubjectCode': '',
  //       'listClassCode': '',
  //       'schoolYear': schoolYear,
  //       'semesterCode': semesterCode,
  //       'subjectDispCode': '',
  //       'operationFormat': ['1', '2'],
  //       'searchList_length': '-1',
  //       '_searchConditionDisp.accordionSearchCondition': 'true',
  //       '_screenIdentifier': 'SC_A03_01_G',
  //       '_screenInfoDisp': '',
  //       '_scrollTop': '0'
  //     }),
  //   );
  //   _updateToken(response.data);
  //   final document = parse(response.data);
  //   for (final quiz in document
  //       .querySelectorAll('#searchList > tbody > tr')
  //       .map(Quiz.fromElement)) {
  //     if (!quizzes.contains(quiz)) {
  //       quizzes.add(quiz);
  //     } else {
  //       quizzes.where((x) => x == quiz).forEach((x) => x.toRefresh(quiz));
  //     }
  //   }
  //   await Wakelock.disable();
  //   return quizzes;
  // }

  // Future<Quiz> getQuiz(Quiz quiz, {bool bypass = false}) async {
  //   await Wakelock.enable();
  //   Document document;
  //   if (!bypass) {
  //     var response = await _client.postUri<dynamic>(
  //       Uri.https('gakujo.shizuoka.ac.jp',
  //           '/portal/common/generalPurpose/', <String, dynamic>{
  //         'org.apache.struts.taglib.html.TOKEN': _token,
  //         'headTitle': '小テスト一覧',
  //         'menuCode': 'A03',
  //         'nextPath': '/test/student/searchList/initialize'
  //       }),
  //     );
  //     _updateToken(response.data);
  //     response = await _client.postUri<dynamic>(
  //       Uri.https('gakujo.shizuoka.ac.jp',
  //           '/portal/test/student/searchList/search', <String, dynamic>{
  //         'org.apache.struts.taglib.html.TOKEN': _token,
  //         'testId': '',
  //         'hidSchoolYear': '',
  //         'hidSemesterCode': '',
  //         'hidSubjectCode': '',
  //         'hidClassCode': '',
  //         'entranceDiv': '',
  //         'backPath': '',
  //         'listSchoolYear': '',
  //         'listSubjectCode': '',
  //         'listClassCode': '',
  //         'schoolYear': schoolYear,
  //         'semesterCode': semesterCode,
  //         'subjectDispCode': '',
  //         'operationFormat': ['1', '2'],
  //         'searchList_length': '-1',
  //         '_searchConditionDisp.accordionSearchCondition': 'true',
  //         '_screenIdentifier': 'SC_A03_01_G',
  //         '_screenInfoDisp': '',
  //         '_scrollTop': '0'
  //       }),
  //     );
  //     _updateToken(response.data);
  //     document = parse(response.data);
  //     if (document
  //         .querySelectorAll('#searchList > tbody > tr')
  //         .map(Quiz.fromElement)
  //         .where((x) => x == quiz)
  //         .isEmpty) {
  //       await Wakelock.disable();
  //       return quiz;
  //     }
  //   }
  //   final response = await _client.postUri<dynamic>(
  //     Uri.https('gakujo.shizuoka.ac.jp',
  //         '/portal/test/student/searchList/forwardSubmitRef', <String, dynamic>{
  //       'org.apache.struts.taglib.html.TOKEN': _token,
  //       'testId': quiz.id,
  //       'hidSchoolYear': '',
  //       'hidSemesterCode': '',
  //       'hidSubjectCode': '',
  //       'hidClassCode': '',
  //       'entranceDiv': '',
  //       'backPath': '',
  //       'listSchoolYear': schoolYear,
  //       'listSubjectCode': quiz.subjectCode,
  //       'listClassCode': quiz.classCode,
  //       'schoolYear': schoolYear,
  //       'semesterCode': semesterCode,
  //       'subjectDispCode': '',
  //       'operationFormat': ['1', '2'],
  //       'searchList_length': '-1',
  //       '_searchConditionDisp.accordionSearchCondition': 'true',
  //       '_screenIdentifier': 'SC_A03_01_G',
  //       '_screenInfoDisp': '',
  //       '_scrollTop': '0'
  //     }),
  //   );
  //   _updateToken(response.data);
  //   document = parse(response.data);
  //   quiz.toDetail(document);
  //   await Wakelock.disable();
  //   return quiz;
  // }
}
