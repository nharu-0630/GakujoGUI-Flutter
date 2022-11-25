import 'dart:developer';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:gakujo_task/models/message.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:version/version.dart';
import 'package:wakelock/wakelock.dart';

class Api {
  static final Version version = Version(1, 0, 0);

  final int year;
  final int semester;
  final String username;
  final String password;

  Dio _client = Dio();
  String _token = '';
  CookieJar _cookieJar = CookieJar();

  Api(this.year, this.semester, this.username, this.password);

  String get schoolYear => year.toString();
  String get semesterCode => (semester < 2 ? 1 : 2).toString();
  String get reportDateStart => '$schoolYear/${semester < 2 ? '04' : '10'}/01';
  String get reportDateEnd => '$schoolYear/${semester < 2 ? '09' : '03'}/01';
  String get suffix => '_${year}_$semesterCode';

  bool _updateToken(dynamic data) {
    _token =
        RegExp(r'(?<="org.apache.struts.taglib.html.TOKEN" value=").*(?=")')
                .firstMatch(data.toString())
                ?.group(0) ??
            _token;
    if (kDebugMode) {
      log(_token);
    }
    return _token != '';
  }

  Future<bool> login() async {
    _client = Dio();
    _cookieJar = CookieJar();
    _client.interceptors.add(CookieManager(_cookieJar));

    var response = await _client.get<dynamic>(
      'https://gakujo.shizuoka.ac.jp/portal/',
    );

    response = await _client.get<dynamic>(
      'https://gakujo.shizuoka.ac.jp/UI/jsp/topPage/topPage.jsp',
    );

    response = await _client.post<dynamic>(
      'https://gakujo.shizuoka.ac.jp/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
      data: FormData.fromMap(<String, dynamic>{
        'selectLocale': 'ja',
        'mistakeChecker': '0',
        'EXCLUDE_SET': '',
      }),
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status! == 302,
      ),
    );

    response = await _client.get<dynamic>(
      response.headers['Location']!.first,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status! == 302,
      ),
    );

    response = await _client.get<dynamic>(
      'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s1',
      options: Options(
        followRedirects: false,
      ),
    );

    response = await _client.post<dynamic>(
      'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s1',
      data: <String, dynamic>{
        'j_username': username,
        'j_password': password,
        '_eventId_proceed': ''
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status == 200,
      ),
    );

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

    response = await _client.post<dynamic>(
      'https://gakujo.shizuoka.ac.jp/Shibboleth.sso/SAML2/POST',
      data: FormData.fromMap(<String, dynamic>{
        'RelayState': relayState,
        'SAMLResponse': samlResponse,
      }),
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) => status! == 302,
      ),
    );

    response = await _client.get<dynamic>(
      'https://gakujo.shizuoka.ac.jp/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
      options: Options(
        followRedirects: false,
      ),
    );

    return _updateToken(response.data);
  }

  Future<List<Message>> getMessages(List<Message> messages) async {
    await Wakelock.enable();
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
    final document = parse(response.data);
    for (final contact in document
        .querySelectorAll('#tbl_A01_01 > tbody > tr')
        .map(Message.fromElement)) {
      if (!messages.contains(contact)) {
        messages.add(contact);
      } else {
        break;
      }
    }
    await Wakelock.disable();
    return messages;
  }

  Future<Message> getMessage(Message message, {bool bypass = false}) async {
    await Wakelock.enable();
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
      final document = parse(response.data);
      index = document
          .querySelectorAll('#tbl_A01_01 > tbody > tr')
          .map(Message.fromElement)
          .toList()
          .indexOf(message);
      if (index == -1) {
        await Wakelock.disable();
        return message;
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
    document = parse(response.data);
    message.toDetail(document);
    await Wakelock.disable();
    return message;
  }

  Future<List<Report>> getReports(List<Report> reports) async {
    await Wakelock.enable();
    var response = await _client.postUri<dynamic>(
      Uri.https('gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/', <String, dynamic>{
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業サポート',
        'menuCode': 'A02',
        'nextPath': '/report/student/searchList/initialize'
      }),
    );
    _updateToken(response.data);
    response = await _client.postUri<dynamic>(
      Uri.https('gakujo.shizuoka.ac.jp',
          '/portal/report/student/searchList/search', <String, dynamic>{
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
        'schoolYear': schoolYear,
        'semesterCode': semesterCode,
        'subjectDispCode': '',
        'operationFormat': ['1', '2'],
        'searchList_length': '-1',
        '_searchConditionDisp.accordionSearchCondition': 'true',
        '_screenIdentifier': 'SC_A02_01_G',
        '_screenInfoDisp': '',
        '_scrollTop': '0'
      }),
    );
    _updateToken(response.data);
    final document = parse(response.data);
    for (final report in document
        .querySelectorAll('#searchList > tbody > tr')
        .map(Report.fromElement)) {
      if (!reports.contains(report)) {
        reports.add(report);
      } else {
        reports.where((x) => x == report).forEach((x) => x.toRefresh(report));
      }
    }
    await Wakelock.disable();
    return reports;
  }

  Future<Report> getReport(Report report, {bool bypass = false}) async {
    await Wakelock.enable();
    Document document;
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https('gakujo.shizuoka.ac.jp',
            '/portal/common/generalPurpose/', <String, dynamic>{
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '授業サポート',
          'menuCode': 'A02',
          'nextPath': '/report/student/searchList/initialize'
        }),
      );
      _updateToken(response.data);
      response = await _client.postUri<dynamic>(
        Uri.https('gakujo.shizuoka.ac.jp',
            '/portal/report/student/searchList/search', <String, dynamic>{
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
          'schoolYear': schoolYear,
          'semesterCode': semesterCode,
          'subjectDispCode': '',
          'operationFormat': ['1', '2'],
          'searchList_length': '-1',
          '_searchConditionDisp.accordionSearchCondition': 'true',
          '_screenIdentifier': 'SC_A02_01_G',
          '_screenInfoDisp': '',
          '_scrollTop': '0'
        }),
      );
      _updateToken(response.data);
      document = parse(response.data);
      if (document
          .querySelectorAll('#searchList > tbody > tr')
          .map(Report.fromElement)
          .where((x) => x == report)
          .isEmpty) {
        await Wakelock.disable();
        return report;
      }
    }
    final response = await _client.postUri<dynamic>(
      Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/report/student/searchList/forwardSubmitRef',
          <String, dynamic>{
            'org.apache.struts.taglib.html.TOKEN': _token,
            'reportId': report.id,
            'hidSchoolYear': '',
            'hidSemesterCode': '',
            'hidSubjectCode': '',
            'hidClassCode': '',
            'entranceDiv': '',
            'backPath': '',
            'listSchoolYear': schoolYear,
            'listSubjectCode': report.subjectCode,
            'listClassCode': report.classCode,
            'schoolYear': schoolYear,
            'semesterCode': semesterCode,
            'subjectDispCode': '',
            'operationFormat': ['1', '2'],
            'searchList_length': '-1',
            '_searchConditionDisp.accordionSearchCondition': 'true',
            '_screenIdentifier': 'SC_A02_01_G',
            '_screenInfoDisp': '',
            '_scrollTop': '0'
          }),
    );
    _updateToken(response.data);
    document = parse(response.data);
    report.toDetail(document);
    await Wakelock.disable();
    return report;
  }

  Future<List<Quiz>> getQuizzes(List<Quiz> quizzes) async {
    await Wakelock.enable();
    var response = await _client.postUri<dynamic>(
      Uri.https('gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/', <String, dynamic>{
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '小テスト一覧',
        'menuCode': 'A03',
        'nextPath': '/test/student/searchList/initialize'
      }),
    );
    _updateToken(response.data);
    response = await _client.postUri<dynamic>(
      Uri.https('gakujo.shizuoka.ac.jp',
          '/portal/test/student/searchList/search', <String, dynamic>{
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
        'schoolYear': schoolYear,
        'semesterCode': semesterCode,
        'subjectDispCode': '',
        'operationFormat': ['1', '2'],
        'searchList_length': '-1',
        '_searchConditionDisp.accordionSearchCondition': 'true',
        '_screenIdentifier': 'SC_A03_01_G',
        '_screenInfoDisp': '',
        '_scrollTop': '0'
      }),
    );
    _updateToken(response.data);
    final document = parse(response.data);
    for (final quiz in document
        .querySelectorAll('#searchList > tbody > tr')
        .map(Quiz.fromElement)) {
      if (!quizzes.contains(quiz)) {
        quizzes.add(quiz);
      } else {
        quizzes.where((x) => x == quiz).forEach((x) => x.toRefresh(quiz));
      }
    }
    await Wakelock.disable();
    return quizzes;
  }

  Future<Quiz> getQuiz(Quiz quiz, {bool bypass = false}) async {
    await Wakelock.enable();
    Document document;
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https('gakujo.shizuoka.ac.jp',
            '/portal/common/generalPurpose/', <String, dynamic>{
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '小テスト一覧',
          'menuCode': 'A03',
          'nextPath': '/test/student/searchList/initialize'
        }),
      );
      _updateToken(response.data);
      response = await _client.postUri<dynamic>(
        Uri.https('gakujo.shizuoka.ac.jp',
            '/portal/test/student/searchList/search', <String, dynamic>{
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
          'schoolYear': schoolYear,
          'semesterCode': semesterCode,
          'subjectDispCode': '',
          'operationFormat': ['1', '2'],
          'searchList_length': '-1',
          '_searchConditionDisp.accordionSearchCondition': 'true',
          '_screenIdentifier': 'SC_A03_01_G',
          '_screenInfoDisp': '',
          '_scrollTop': '0'
        }),
      );
      _updateToken(response.data);
      document = parse(response.data);
      if (document
          .querySelectorAll('#searchList > tbody > tr')
          .map(Quiz.fromElement)
          .where((x) => x == quiz)
          .isEmpty) {
        await Wakelock.disable();
        return quiz;
      }
    }
    final response = await _client.postUri<dynamic>(
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
        'listSchoolYear': schoolYear,
        'listSubjectCode': quiz.subjectCode,
        'listClassCode': quiz.classCode,
        'schoolYear': schoolYear,
        'semesterCode': semesterCode,
        'subjectDispCode': '',
        'operationFormat': ['1', '2'],
        'searchList_length': '-1',
        '_searchConditionDisp.accordionSearchCondition': 'true',
        '_screenIdentifier': 'SC_A03_01_G',
        '_screenInfoDisp': '',
        '_scrollTop': '0'
      }),
    );
    _updateToken(response.data);
    document = parse(response.data);
    quiz.toDetail(document);
    await Wakelock.disable();
    return quiz;
  }
}