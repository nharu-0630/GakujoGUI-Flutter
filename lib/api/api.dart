import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:gakujo_task/api/parse.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/class_link.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/grade.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/models/shared_file.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';

class Api {
  static final version = Version(1, 4, 0);

  final _interval = const Duration(milliseconds: 200);

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
    var settings = await _settings;
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
        'User-Agent': 'Chrome/110.0.5481.104 GakujoTask/$version',
      },
      contentType: Headers.formUrlEncodedContentType,
      followRedirects: false,
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
      options: Options(
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        },
      ),
    );

    await Future.delayed(_interval);
    _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/UI/jsp/topPage/topPage.jsp',
        {'_': DateTime.now().millisecondsSinceEpoch.toString()},
      ),
      options: Options(
        headers: {
          'Accept': 'text/html, */*; q=0.01',
          'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
        },
      ),
    );

    await Future.delayed(_interval);
    await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/login/preLogin/preLogin',
      ),
      data: {'mistakeChecker': '0'},
      options: Options(
        headers: {
          'Accept': 'application/json, text/javascript, */*; q=0.01',
          'Origin': 'https://gakujo.shizuoka.ac.jp',
          'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
        },
      ),
    );

    await Future.delayed(_interval);
    _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/UI/jsp/topPage/topPage.jsp',
        {'_': DateTime.now().millisecondsSinceEpoch.toString()},
      ),
      options: Options(
        headers: {
          'Accept': 'text/html, */*; q=0.01',
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
      data: {
        'selectLocale': 'ja',
        'mistakeChecker': '0',
        'EXCLUDE_SET': '',
      },
      options: Options(
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Origin': 'https://gakujo.shizuoka.ac.jp',
          'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
        },
        validateStatus: (status) => status == 302,
      ),
    );

    await Future.delayed(_interval);
    response = await _client.get<dynamic>(
      response.headers.value('location')!,
      options: Options(
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Referer': 'https://gakujo.shizuoka.ac.jp/portal/',
        },
        validateStatus: (status) => status == 302 || status == 200,
      ),
    );

    if (response.statusCode == 302) {
      await Future.delayed(_interval);
      await _client.getUri<dynamic>(
        Uri.https(
          'idp.shizuoka.ac.jp',
          '/idp/profile/SAML2/Redirect/SSO',
          {'execution': 'e1s1'},
        ),
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Referer': 'https://gakujo.shizuoka.ac.jp/',
          },
        ),
      );

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'idp.shizuoka.ac.jp',
          '/idp/profile/SAML2/Redirect/SSO',
          {'execution': 'e1s1'},
        ),
        data: {
          'j_username': await _username,
          'j_password': await _password,
          '_eventId_proceed': '',
        },
        options: Options(
          headers: {
            'Origin': 'https://idp.shizuoka.ac.jp',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
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
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Origin': 'https://idp.shizuoka.ac.jp',
          'Referer': 'https://idp.shizuoka.ac.jp/',
        },
        validateStatus: (status) => status == 302,
      ),
    );

    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
      ),
      options: Options(
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Referer': 'https://idp.shizuoka.ac.jp/',
        },
        validateStatus: (status) => status == 302 || status == 200,
      ),
    );

    if (response.statusCode == 302) {
      await Future.delayed(_interval);
      response = await _client.get<dynamic>(
        response.headers.value('location')!,
      );
    }

    _updateToken(response.data);

    samlResponse = Uri.decodeFull(
      RegExp(r'(?<=SAMLResponse" value=").*(?=")')
              .firstMatch(response.data.toString())
              ?.group(0) ??
          '',
    );
    relayState = Uri.decodeFull(
      RegExp(r'(?<=RelayState" value=").*(?=")')
              .firstMatch(response.data.toString())
              ?.group(0) ??
          '',
    ).replaceAll('&#x3a;', ':');

    if (samlResponse.isNotEmpty && relayState.isNotEmpty) {
      if (kDebugMode) {
        print('SAMLResponse: ${samlResponse.substring(0, 10)} ...');
        print('RelayState: ${relayState.substring(0, 10)} ...');
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
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Origin': 'https://idp.shizuoka.ac.jp',
            'Referer': 'https://idp.shizuoka.ac.jp/',
          },
          validateStatus: (status) => status == 302,
        ),
      );

      await Future.delayed(_interval);
      response = await _client.getUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
        ),
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          },
        ),
      );
    }

    final Settings? settings = await _settings;
    if (parse(response.data).querySelector('title')!.text == 'アクセス環境登録') {
      var accessEnvName = 'GakujoTask ${(const Uuid()).v4().substring(0, 8)}';

      settings?.accessEnvironmentName = accessEnvName;
      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/accessEnvironmentRegist/goHome/',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'accessEnvName': accessEnvName,
          'newAccessKey': '',
        },
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Origin': 'https://gakujo.shizuoka.ac.jp',
            'Referer':
                'https://gakujo.shizuoka.ac.jp/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
          },
        ),
      );

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/home/home/initialize',
          {'EXCLUDE_SET': ''},
        ),
        data: {'EXCLUDE_SET': ''},
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Origin': 'https://gakujo.shizuoka.ac.jp',
            'Referer':
                'https://gakujo.shizuoka.ac.jp/portal/common/accessEnvironmentRegist/goHome/',
          },
        ),
      );
    } else {
      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/home/home/initialize',
        ),
        data: {'EXCLUDE_SET': ''},
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
            'Origin': 'https://gakujo.shizuoka.ac.jp',
            'Referer':
                'https://gakujo.shizuoka.ac.jp/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
          },
        ),
      );
    }

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

    await navigatorKey.currentContext?.watch<SubjectRepository>().deleteAll();
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

  Future<void> fetchSharedFiles() async {
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/common/generalPurpose/',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業共有ファイル',
        'menuCode': 'A08',
        'nextPath': '/classfile/classFile/initialize'
      },
    );
    _updateToken(response.data, required: true);

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/classfile/classFile/selectClassFileList',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'searchKeyWord': '',
        'searchScopeTitle': 'Y',
        'lastUpdateDate': '',
        'tbl_classFile_length': '-1',
        'linkDetailIndex': '0',
        'selectIndex': '',
        'prevPageId': 'backToList',
        'confirmMsg': '',
      },
    );
    _updateToken(response.data, required: true);

    navigatorKey.currentContext?.read<SharedFileRepository>().addAll(
        parse(response.data)
            .querySelectorAll('#tbl_classFile > tbody > tr')
            .map(SharedFile.fromElement)
            .toList());
  }

  Future<SharedFile> fetchDetailSharedFile(SharedFile sharedFile,
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
          'headTitle': '授業共有ファイル',
          'menuCode': 'A08',
          'nextPath': '/classfile/classFile/initialize'
        },
      );
      _updateToken(response.data, required: true);

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classfile/classFile/selectClassFileList',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'schoolYear': await _schoolYear,
          'semesterCode': await _semesterCode,
          'subjectDispCode': '',
          'searchKeyWord': '',
          'searchScopeTitle': 'Y',
          'lastUpdateDate': '',
          'tbl_classFile_length': '-1',
          'linkDetailIndex': '0',
          'selectIndex': '',
          'prevPageId': 'backToList',
          'confirmMsg': '',
        },
      );
      _updateToken(response.data, required: true);

      index = parse(response.data)
          .querySelectorAll('#tbl_classFile > tbody > tr')
          .map(SharedFile.fromElement)
          .toList()
          .indexOf(sharedFile);
      if (index == -1) {
        return sharedFile;
      }
    }

    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classfile/classFile/showClassFileDetail/$index',
          <String, dynamic>{
            'org.apache.struts.taglib.html.TOKEN': _token,
            'teacherCode': '',
            'schoolYear': await _schoolYear,
            'semesterCode': await _semesterCode,
            'subjectDispCode': '',
            'searchKeyWord': '',
            'searchScopeTitle': 'Y',
            'lastUpdateDate': '',
            'tbl_classFile_length': '-1',
            'linkDetailIndex': [
              '0',
              '1',
              '2',
              '3',
              '4',
              '5',
              '6',
              '7',
              '8',
              '9',
            ],
            'selectIndex': '',
            'prevPageId': 'backToList',
            'confirmMsg': '',
            '_searchConditionDisp.accordionSearchCondition': 'true',
            '_screenIdentifier': 'SC_A08_01',
            '_screenInfoDisp': 'true',
            '_scrollTop': '0',
          }),
    );
    _updateToken(response.data, required: true);
    var document = parse(response.data);
    sharedFile.fileNames = [];
    var dir = await getApplicationDocumentsDirectory();
    for (var node in document
        .querySelector('#fileList_CLASS_FILE_FILE')!
        .querySelectorAll('div > a')) {
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
        },
        options: Options(responseType: ResponseType.bytes),
      );
      var file = File(join(dir.path, basename(node.text.trim())));
      file.writeAsBytes(response.data);
      sharedFile.fileNames?.add(basename(node.text.trim()));
    }

    sharedFile.toDetail(document);
    navigatorKey.currentContext
        ?.read<SharedFileRepository>()
        .add(sharedFile, overwrite: true);
    return sharedFile;
  }

  Future<void> fetchClassLinks() async {
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/common/generalPurpose/',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業リンク一覧',
        'menuCode': 'A09',
        'nextPath': '/classlink/classLinkList/initialize'
      },
    );
    _updateToken(response.data, required: true);

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/classlink/classLinkList/searchClassLinkList',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'searchTeacherName': '',
        'searchTeacherCode': '',
        'searchSchoolYear': await _schoolYear,
        'searchEstablishSemester': await _semesterCode,
        'searchClassSubject': '',
        'searchKeyword': '',
        'checkSearchLinkTitle': 'on',
        'tbl_classLinkList_length': '-1',
        'linkId': '',
        'confirmMsg': '',
      },
    );
    _updateToken(response.data, required: true);

    navigatorKey.currentContext?.read<ClassLinkRepository>().addAll(
        parse(response.data)
            .querySelectorAll('#tbl_classLinkList > tbody > tr')
            .map(ClassLink.fromElement)
            .toList());
  }

  Future<ClassLink> fetchDetailClassLink(ClassLink classLink,
      {bool bypass = false}) async {
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '授業リンク一覧',
          'menuCode': 'A09',
          'nextPath': '/classlink/classLinkList/initialize'
        },
      );
      _updateToken(response.data, required: true);

      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classlink/classLinkList/searchClassLinkList',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'searchTeacherName': '',
          'searchTeacherCode': '',
          'searchSchoolYear': await _schoolYear,
          'searchEstablishSemester': await _semesterCode,
          'searchClassSubject': '',
          'searchKeyword': '',
          'checkSearchLinkTitle': 'on',
          'tbl_classLinkList_length': '-1',
          'linkId': '',
          'confirmMsg': '',
        },
      );
      _updateToken(response.data, required: true);

      if (parse(response.data)
          .querySelectorAll('#tbl_classLinkList > tbody > tr')
          .map(ClassLink.fromElement)
          .where((e) => e == classLink)
          .isEmpty) {
        return classLink;
      }
    }
    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/classlink/classLinkList/moveToDetail',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'searchTeacherName': '',
        'searchTeacherCode': '',
        'searchSchoolYear': await _schoolYear,
        'searchEstablishSemester': await _semesterCode,
        'searchClassSubject': '',
        'searchKeyword': '',
        'checkSearchLinkTitle': 'on',
        'tbl_classLinkList_length': '-1',
        'linkId': classLink.id,
        'confirmMsg': '',
      },
    );
    _updateToken(response.data, required: true);
    var document = parse(response.data);
    classLink.toDetail(document);
    navigatorKey.currentContext
        ?.read<ClassLinkRepository>()
        .add(classLink, overwrite: true);
    return classLink;
  }

  Future<bool> fetchAcademicSystem() async {
    await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/preLogin.do',
      ),
      options: Options(
        headers: {
          'Origin': 'https://gakujo.shizuoka.ac.jp',
          'Referer':
              'https://gakujo.shizuoka.ac.jp/portal/home/home/initialize?EXCLUDE_SET=',
        },
      ),
    );

    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/home/systemCooperationLink/initializeShibboleth',
        {
          'renkeiType': 'kyoumu',
        },
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
      },
      options: Options(
        headers: {
          'Origin': 'https://gakujo.shizuoka.ac.jp',
          'Referer':
              'https://gakujo.shizuoka.ac.jp/portal/home/home/initialize?EXCLUDE_SET=',
        },
      ),
    );

    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/sso/loginStudent.do',
      ),
      data: 'loginID=',
      options: Options(
        headers: {
          'Origin': 'https://gakujo.shizuoka.ac.jp',
          'Referer':
              'https://gakujo.shizuoka.ac.jp/portal/home/systemCooperationLink/initializeShibboleth?renkeiType=kyoumu'
        },
        validateStatus: (status) => status == 302 || status == 200,
      ),
    );

    if (response.statusCode == 302) {
      await Future.delayed(_interval);
      response = await _client.get<dynamic>(
        response.headers.value('location')!,
      );

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
          validateStatus: (status) => status == 302,
        ),
      );
    }
    return true;
  }

  Future<void> fetchGrades() async {
    await fetchAcademicSystem();

    await Future.delayed(_interval);
    var response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/seisekiSearchStudentInit.do',
        {
          'mainMenuCode': '008',
          'parentMenuCode': '007',
        },
      ),
    );
    var document = parse(response.data);

    if (document.querySelector('table.txt12') != null) {
      await navigatorKey.currentContext?.read<GradeRepository>().deleteAll();
      if (kDebugMode) {
        print(document
            .querySelector('table.txt12')!
            .querySelectorAll('tr')
            .skip(1)
            .map(Grade.fromElement)
            .toList());
      }
      navigatorKey.currentContext?.read<GradeRepository>().addAll(document
          .querySelector('table.txt12')!
          .querySelectorAll('tr')
          .skip(1)
          .map(Grade.fromElement)
          .toList());
    }
  }
}
