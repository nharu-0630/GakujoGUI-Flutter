import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/models/class_link.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/gpa.dart';
import 'package:gakujo_gui/models/grade.dart';
import 'package:gakujo_gui/models/questionnaire.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/models/subject.dart';
import 'package:gakujo_gui/models/timetable.dart';
import 'package:html/parser.dart' show parse;
import 'package:otp/otp.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:version/version.dart';

class GakujoApi {
  static final version = Version(1, 7, 0);
  static final userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36 GakujoAPI/$version';
  static const _interval = Duration(milliseconds: 250);

  late Dio _client;
  late CookieJar _cookieJar;
  String _token = '';
  String get token => _token;

  final BuildContext? _context = App.navigatorKey.currentContext;

  final String username;
  final String password;
  final String secret;
  final int year;
  final int semester;

  String get _schoolYear => year.toString();
  String get _semesterCode => (semester < 2 ? 1 : 2).toString();
  String get _reportDateStart => '$year/${semester < 2 ? '04' : '10'}/01';

  bool _updateToken(dynamic data, {bool required = false}) {
    _token =
        RegExp(r'(?<="org.apache.struts.taglib.html.TOKEN" value=").*(?=")')
                .firstMatch(data.toString())
                ?.group(0) ??
            '';
    if (kDebugMode) print('Token: $_token');
    if (required && _token.isEmpty) {
      throw Exception('Failed to update Struts TransactionToken.');
    }
    return _token.isNotEmpty;
  }

  void _setProgress(double value) =>
      _context?.read<ApiRepository>().setProgress(value);

  GakujoApi({
    required this.username,
    required this.password,
    required this.secret,
    required this.year,
    required this.semester,
  });

  Future<void> initialize(Cookie? accessEnvironment) async {
    _client = Dio(BaseOptions(
      headers: {
        'User-Agent': userAgent,
      },
      contentType: Headers.formUrlEncodedContentType,
      followRedirects: false,
      responseType: ResponseType.plain,
    ));
    _token = '';
    _cookieJar = CookieJar();
    if (accessEnvironment != null) {
      _cookieJar.saveFromResponse(
          Uri.https('gakujo.shizuoka.ac.jp', '/portal'), [accessEnvironment]);
    }
    _client.interceptors.add(CookieManager(_cookieJar));
    _client.interceptors.add(LogInterceptor());
  }

  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  Future<void> fetchLogin() async {
    _setProgress(0 / 15);
    await Future.delayed(_interval);
    await _client.getUri<dynamic>(
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

    _setProgress(1 / 15);
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

    _setProgress(2 / 15);
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
        validateStatus: (status) => status == 302 || status == 200,
      ),
    );

    if (response.statusCode == 302) {
      if (response.headers.value('location') == null) {
        throw Exception('Failed to get location header.');
      }

      _setProgress(3 / 15);
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

      String? jsessionid;

      if (response.statusCode == 302) {
        if (response.headers.value('set-cookie') == null) {
          throw Exception('Failed to get set-cookie header.');
        }

        var idpSession = RegExp(r'(?<=JSESSIONID=).*?(?=;)')
            .firstMatch(response.headers.value('set-cookie')!)
            ?.group(0);

        if (idpSession == null) {
          throw Exception('Failed to get IdPSession.');
        }

        _setProgress(4 / 15);
        await Future.delayed(_interval);
        response = await _client.getUri<dynamic>(
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
              'Cookie': 'JSESSIONID=$idpSession',
            },
          ),
        );

        var csrftoken = RegExp(r'(?<=csrf_token" value=").*(?=")')
            .firstMatch(response.data.toString())
            ?.group(0);
        if (csrftoken == null) {
          throw Exception('Failed to get csrf_token.');
        }

        // jsessionid = null;
        // for (var element in response.headers['set-cookie']!) {
        //   if (element.contains('JSESSIONID')) {
        //     jsessionid = RegExp(r'(?<=JSESSIONID=).*?(?=;)')
        //         .firstMatch(element)!
        //         .group(0)!;
        //   }
        // }
        // if (jsessionid == null) {
        //   throw Exception('Failed to get JSESSIONID.');
        // }
        jsessionid = idpSession;

        _setProgress(5 / 15);
        await Future.delayed(_interval);
        response = await _client.postUri<dynamic>(
          Uri.https(
            'idp.shizuoka.ac.jp',
            '/idp/profile/SAML2/Redirect/SSO',
            {'execution': 'e1s1'},
          ),
          data: {
            'csrf_token': csrftoken,
            'shib_idp_ls_exception.shib_idp_session_ss': '',
            'shib_idp_ls_success.shib_idp_session_ss': true,
            'shib_idp_ls_value.shib_idp_session_ss': '',
            'shib_idp_ls_exception.shib_idp_persistent_ss': '',
            'shib_idp_ls_success.shib_idp_persistent_ss': true,
            'shib_idp_ls_value.shib_idp_persistent_ss': '',
            'shib_idp_ls_supported': true,
            '_eventId_proceed': '',
          },
          options: Options(
            headers: {
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
              'Origin': 'https://idp.shizuoka.ac.jp',
              'Referer':
                  'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s1',
              'Cookie': 'JSESSIONID=$idpSession',
            },
            validateStatus: (status) => status == 302 || status == 200,
          ),
        );
      }

      if (response.statusCode == 302) {
        if (response.headers.value('location') == null) {
          throw Exception('Failed to get location header.');
        }

        _setProgress(6 / 15);
        await Future.delayed(_interval);
        response = await _client.get<dynamic>(
          response.headers.value('location')!,
          options: Options(
            headers: {
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
              'Referer':
                  'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s1',
            },
            validateStatus: (status) => status == 302 || status == 200,
          ),
        );

        if (response.statusCode == 302) {
          if (response.headers.value('location') == null) {
            throw Exception('Failed to get location header.');
          }

          _setProgress(7 / 15);
          await Future.delayed(_interval);
          response = await _client.get<dynamic>(
            response.headers.value('location')!,
            options: Options(
              headers: {
                'Accept':
                    'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                'Referer':
                    'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s1',
              },
              validateStatus: (status) => status == 302 || status == 200,
            ),
          );

          if (response.statusCode == 302) {
            if (response.headers.value('location') == null) {
              throw Exception('Failed to get location header.');
            }

            var msurl = response.headers.value('location')!;

            _setProgress(8 / 15);
            await Future.delayed(_interval);
            response = await _client.get<dynamic>(
              msurl,
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer': 'https://idp.shizuoka.ac.jp/',
                },
              ),
            );

            String? fpc;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('fpc')) {
                fpc =
                    RegExp(r'(?<=fpc=).*?(?=;)').firstMatch(element)!.group(0)!;
              }
            }

            if (fpc == null) {
              throw Exception('Failed to get fpc.');
            }

            _setProgress(9 / 15);
            await Future.delayed(_interval);
            response = await _client.get<dynamic>(
              '$msurl&sso_reload=true',
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer': msurl,
                  'Cookie':
                      'fpc=$fpc; x-ms-gateway-slice=estsfd; stsservicecookie=estsfd; AADSSO=NA|NoExtension; SSOCOOKIEPULLED=1',
                },
              ),
            );

            String? buid;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('buid')) {
                buid = RegExp(r'(?<=buid=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (buid == null) {
              throw Exception('Failed to get buid.');
            }

            String? esctx;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('esctx')) {
                esctx = RegExp(r'(?<=esctx=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (esctx == null) {
              throw Exception('Failed to get esctx.');
            }

            fpc = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('fpc')) {
                fpc =
                    RegExp(r'(?<=fpc=).*?(?=;)').firstMatch(element)!.group(0)!;
              }
            }
            if (fpc == null) {
              throw Exception('Failed to get fpc.');
            }

            var hpgrequestid = response.headers.value('x-ms-request-id');
            if (hpgrequestid == null) {
              throw Exception('Failed to get x-ms-request-id.');
            }

            var clientrequestid = RegExp(r'(?<="correlationId":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (clientrequestid == null) {
              throw Exception('Failed to get correlationId.');
            }

            var canary = RegExp(r'(?<="apiCanary":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (canary == null) {
              throw Exception('Failed to get apiCanary.');
            }

            var canary2 = RegExp(r'(?<="canary":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (canary2 == null) {
              throw Exception('Failed to get canary.');
            }

            var originalrequest = RegExp(r'(?<="sCtx":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (originalrequest == null) {
              throw Exception('Failed to get sCtx.');
            }

            var flowtoken = RegExp(r'(?<="sFT":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (flowtoken == null) {
              throw Exception('Failed to get sFT.');
            }

            _setProgress(10 / 15);
            await Future.delayed(_interval);
            response = await _client.getUri<dynamic>(
              Uri.https(
                'login.live.com',
                '/Me.htm',
                {'v': '3'},
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer': 'https://login.microsoftonline.com/',
                },
              ),
            );

            String? uaid;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('uaid')) {
                uaid = RegExp(r'(?<=uaid=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (uaid == null) {
              throw Exception('Failed to get uaid.');
            }

            String? msprequ;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('MSPRequ')) {
                msprequ = RegExp(r'(?<=MSPRequ=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (msprequ == null) {
              throw Exception('Failed to get MSPRequ.');
            }

            _setProgress(11 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri<dynamic>(
              Uri.https(
                'login.microsoftonline.com',
                '/common/GetCredentialType',
                {'mkt': 'ja'},
              ),
              options: Options(
                headers: {
                  'Accept': 'application/json',
                  'Referer': '$msurl&sso_reload=true',
                  'Cookie':
                      'brcap=0; x-ms-gateway-slice=estsfd; stsservicecookie=estsfd; AADSSO=NA|NoExtension; buid=$buid; esctx=$esctx; fpc=$fpc',
                  'Hpgrequestid': hpgrequestid,
                  'Client-Request-Id': clientrequestid,
                  'Canary': canary,
                },
                contentType: Headers.jsonContentType,
              ),
              data: {
                'username': username,
                'isOtherIdpSupported': true,
                'checkPhones': false,
                'isRemoteNGCSupported': true,
                'isCookieBannerShown': false,
                'isFidoSupported': true,
                'originalRequest': originalrequest,
                'country': 'JP',
                'forceotclogin': false,
                'isExternalFederationDisallowed': false,
                'isRemoteConnectSupported': false,
                'federationFlags': 0,
                'isSignup': false,
                'flowToken': flowtoken,
                'isAccessPassSupported': true
              },
            );

            var guid = msurl.replaceFirst('https://', '').split('/')[1];
            var st = DateTime.now().microsecondsSinceEpoch;

            flowtoken = null;
            flowtoken = RegExp(r'(?<="FlowToken":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (flowtoken == null) {
              throw Exception('Failed to get FlowToken.');
            }

            _setProgress(12 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'login.microsoftonline.com',
                '/$guid/login',
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer': '$msurl&sso_reload=true',
                  'Cookie':
                      'brcap=0; x-ms-gateway-slice=estsfd; stsservicecookie=estsfd; AADSSO=NA|NoExtension; buid=$buid; esctx=$esctx; fpc=$fpc; wlidperf=FR=L&ST=$st',
                },
              ),
              data: {
                'i13': 0,
                'login': username,
                'loginfmt': username,
                'type': 11,
                'LoginOptions': 3,
                'lrt': '',
                'lrtPartition': '',
                'hisRegion': '',
                'hisScaleUnit': '',
                'passwd': password,
                'ps': 2,
                'psRNGCDefaultType': '',
                'psRNGCEntropy': '',
                'psRNGCSLK': '',
                'canary': canary2,
                'ctx': originalrequest,
                'hpgrequestid': hpgrequestid,
                'flowToken': flowtoken,
                'PPSX': '',
                'NewUser': 1,
                'FoundMSAs': '',
                'fspost': 0,
                'i21': 0,
                'CookieDisclosure': 0,
                'IsFidoSupported': 1,
                'isSignupPost': 0,
                'i19': 1000,
              },
            );

            hpgrequestid = null;
            hpgrequestid = response.headers.value('x-ms-request-id');
            if (hpgrequestid == null) {
              throw Exception('Failed to get x-ms-request-id.');
            }

            clientrequestid = null;
            clientrequestid = RegExp(r'(?<="correlationId":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (clientrequestid == null) {
              throw Exception('Failed to get correlationId.');
            }

            canary = null;
            canary = RegExp(r'(?<="apiCanary":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (canary == null) {
              throw Exception('Failed to get apiCanary.');
            }

            String? instrumentationkey;
            instrumentationkey = RegExp(r'(?<="instrumentationKey":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (instrumentationkey == null) {
              throw Exception('Failed to get instrumentationKey.');
            }

            String? estsauthpersistent;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('ESTSAUTHPERSISTENT')) {
                estsauthpersistent = RegExp(r'(?<=ESTSAUTHPERSISTENT=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (estsauthpersistent == null) {
              throw Exception('Failed to get estsauthpersistent.');
            }

            String? estsauth;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('ESTSAUTH')) {
                if (RegExp(r'(?<=ESTSAUTH=).*?(?=;)').firstMatch(element) !=
                    null) {
                  estsauth = RegExp(r'(?<=ESTSAUTH=).*?(?=;)')
                      .firstMatch(element)!
                      .group(0)!;
                }
              }
            }
            if (estsauth == null) {
              throw Exception('Failed to get estsauth.');
            }

            String? estsauthlight;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('ESTSAUTHLIGHT')) {
                estsauthlight = RegExp(r'(?<=ESTSAUTHLIGHT=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (estsauthlight == null) {
              throw Exception('Failed to get estsauthlight.');
            }

            buid = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('buid')) {
                buid = RegExp(r'(?<=buid=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (buid == null) {
              throw Exception('Failed to get buid.');
            }

            esctx = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('esctx')) {
                esctx = RegExp(r'(?<=esctx=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (esctx == null) {
              throw Exception('Failed to get esctx.');
            }

            fpc = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('fpc')) {
                fpc =
                    RegExp(r'(?<=fpc=).*?(?=;)').firstMatch(element)!.group(0)!;
              }
            }
            if (fpc == null) {
              throw Exception('Failed to get fpc.');
            }

            var ctx = RegExp(r'(?<="sCtx":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (ctx == null) {
              throw Exception('Failed to get sCtx.');
            }

            flowtoken = null;
            flowtoken = RegExp(r'(?<="sFT":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (flowtoken == null) {
              throw Exception('Failed to get sFT.');
            }

            _setProgress(13 / 15);
            await Future.delayed(_interval);
            response = await _client.getUri<dynamic>(
              Uri.https(
                'login.live.com',
                '/Me.htm',
                {'v': '3'},
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer': 'https://login.microsoftonline.com/',
                },
              ),
            );

            uaid = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('uaid')) {
                uaid = RegExp(r'(?<=uaid=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (uaid == null) {
              throw Exception('Failed to get uaid.');
            }

            msprequ = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('MSPRequ')) {
                msprequ = RegExp(r'(?<=MSPRequ=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (msprequ == null) {
              throw Exception('Failed to get MSPRequ.');
            }

            _setProgress(14 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'login.microsoftonline.com',
                '/common/SAS/BeginAuth',
              ),
              options: Options(
                headers: {
                  'Accept': 'application/json',
                  'Referer': 'https://login.microsoftonline.com/$guid/login',
                  'Cookie':
                      'x-ms-gateway-slice=estsfd; stsservicecookie=estsfd; AADSSO=NA|NoExtension; SSOCOOKIEPULLED=1; brcap=0; wlidperf=FR=L&ST=$st; ESTSAUTHPERSISTENT=$estsauthpersistent; ESTSAUTH=$estsauth; ESTSAUTHLIGHT=$estsauthlight; buid=$buid; esctx=$esctx; fpc=$fpc',
                  'Hpgrequestid': hpgrequestid,
                  'Client-Request-Id': clientrequestid,
                  'Canary': canary,
                },
                contentType: Headers.jsonContentType,
              ),
              data: {
                "AuthMethodId": "PhoneAppOTP",
                "Method": "BeginAuth",
                "ctx": ctx,
                "flowToken": flowtoken
              },
            );

            var sessionid = RegExp(r'(?<="SessionId":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (sessionid == null) {
              throw Exception('Failed to get SessionId.');
            }

            flowtoken = null;
            flowtoken = RegExp(r'(?<="FlowToken":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (flowtoken == null) {
              throw Exception('Failed to get FlowToken.');
            }

            ctx = null;
            ctx = RegExp(r'(?<="Ctx":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (ctx == null) {
              throw Exception('Failed to get Ctx.');
            }

            var epoch = DateTime.now().millisecondsSinceEpoch;
            var otc = OTP.generateTOTPCode(secret, epoch,
                length: 6,
                interval: 30,
                algorithm: Algorithm.SHA1,
                isGoogle: true);

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'login.microsoftonline.com',
                '/common/SAS/EndAuth',
              ),
              options: Options(
                headers: {
                  'Accept': 'application/json',
                  'Referer': 'https://login.microsoftonline.com/$guid/login',
                  'Cookie':
                      'x-ms-gateway-slice=estsfd; stsservicecookie=estsfd; AADSSO=NA|NoExtension; SSOCOOKIEPULLED=1; brcap=0; wlidperf=FR=L&ST=$st; ESTSAUTHPERSISTENT=$estsauthpersistent; ESTSAUTH=$estsauth; ESTSAUTHLIGHT=$estsauthlight; buid=$buid; esctx=$esctx; fpc=$fpc',
                  'Hpgrequestid': hpgrequestid,
                  'Client-Request-Id': clientrequestid,
                  'Canary': canary,
                },
                contentType: Headers.jsonContentType,
              ),
              data: {
                "Method": "EndAuth",
                "SessionId": sessionid,
                "FlowToken": flowtoken,
                "Ctx": ctx,
                "AuthMethodId": "PhoneAppOTP",
                "AdditionalAuthData": otc.toString(),
                "PollCount": 1
              },
            );

            flowtoken = null;
            flowtoken = RegExp(r'(?<="FlowToken":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (flowtoken == null) {
              throw Exception('Failed to get FlowToken.');
            }

            fpc = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('fpc')) {
                fpc =
                    RegExp(r'(?<=fpc=).*?(?=;)').firstMatch(element)!.group(0)!;
              }
            }
            if (fpc == null) {
              throw Exception('Failed to get fpc.');
            }

            print('==========================');
            print(response.data);
            print('==========================');

            String? timestamp = null;
            timestamp = RegExp(r'(?<="Timestamp":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (timestamp == null) {
              throw Exception('Failed to get Timestamp.');
            }
            timestamp = DateTime.parse(timestamp)
                .millisecondsSinceEpoch
                .toString()
                .substring(0, 10);

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'login.microsoftonline.com',
                '/common/SAS/ProcessAuth',
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer': 'https://login.microsoftonline.com/$guid/login',
                  'Cookie':
                      'AADSSO=NA|NoExtension; SSOCOOKIEPULLED=1; brcap=0; wlidperf=FR=L&ST=$st',
                },
              ),
              data: {
                "type": 19,
                "GeneralVerify": false,
                "request": ctx,
                "mfaLastPollStart": epoch,
                "mfaLastPollEnd": '${timestamp}000',
                "mfaAuthMethod": "PhoneAppOTP",
                "otc": otc,
                "login": username,
                "flowToken": flowtoken,
                "hpgrequestid": hpgrequestid,
                "sacxt": "",
                "hideSmsInMfaProofs": false,
                "canary": canary2,
                "i19": 1000,
              },
            );

            hpgrequestid = null;
            hpgrequestid = response.headers.value('x-ms-request-id');
            if (hpgrequestid == null) {
              throw Exception('Failed to get x-ms-request-id.');
            }

            flowtoken = null;
            flowtoken = RegExp(r'(?<="sFT":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (flowtoken == null) {
              throw Exception('Failed to get sFT.');
            }

            canary = null;
            canary = RegExp(r'(?<="canary":").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (canary == null) {
              throw Exception('Failed to get canary.');
            }

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.getUri<dynamic>(
              Uri.https(
                'login.live.com',
                '/Me.htm',
                {'v': '3'},
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer': 'https://login.microsoftonline.com/',
                  'Cookie': 'uaid=$uaid; MSPRequ=$msprequ',
                },
              ),
            );

            uaid = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('uaid')) {
                uaid = RegExp(r'(?<=uaid=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (uaid == null) {
              throw Exception('Failed to get uaid.');
            }

            msprequ = null;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('MSPRequ')) {
                msprequ = RegExp(r'(?<=MSPRequ=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (msprequ == null) {
              throw Exception('Failed to get MSPRequ.');
            }

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'login.microsoftonline.com',
                '/kmsi',
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Referer':
                      'https://login.microsoftonline.com/common/SAS/ProcessAuth',
                },
              ),
              data: {
                "LoginOptions": 1,
                "type": 28,
                "ctx": ctx,
                "hpgrequestid": hpgrequestid,
                "flowToken": flowtoken,
                "DontShowAgain": true,
                "canary": canary,
                "i19": 1000,
              },
            );

            print(response.data);

            var samlresponse = RegExp(r'(?<=SAMLResponse" value=").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (samlresponse == null) {
              throw Exception('Failed to get SAMLResponse.');
            }

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'idp.shizuoka.ac.jp',
                '/idp/profile/Authn/SAML2/POST/SSO ',
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Cookie': 'JSESSIONID=$jsessionid',
                  'Origin': 'https://login.microsoftonline.com',
                },
                validateStatus: (status) => status == 302,
              ),
              data: {
                'SAMLResponse': samlresponse,
                'RelayState': "e1s2",
              },
            );

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.getUri(
              Uri.https(
                'idp.shizuoka.ac.jp',
                '/idp/profile/SAML2/Redirect/SSO',
                {
                  'execution': 'e1s2',
                  '_eventId_proceed': 1,
                },
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Cookie': 'JSESSIONID=$jsessionid',
                  'Referer': 'https://login.microsoftonline.com/',
                },
                validateStatus: (status) => status == 302,
              ),
            );

            String? shibidpsession;
            for (var element in response.headers['set-cookie']!) {
              if (element.contains('shib_idp_session')) {
                shibidpsession = RegExp(r'(?<=shib_idp_session=).*?(?=;)')
                    .firstMatch(element)!
                    .group(0)!;
              }
            }
            if (shibidpsession == null) {
              throw Exception('Failed to get shib_idp_session.');
            }

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.getUri(
              Uri.https(
                'idp.shizuoka.ac.jp',
                '/idp/profile/SAML2/Redirect/SSO',
                {
                  'execution': 'e1s3',
                },
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                  'Cookie':
                      'JSESSIONID=$jsessionid; shib_idp_session=$shibidpsession',
                  'Referer': 'https://login.microsoftonline.com/',
                },
              ),
            );

            var csrftoken = RegExp(r'(?<=csrf_token" value=").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (csrftoken == null) {
              throw Exception('Failed to get csrf_token.');
            }

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'idp.shizuoka.ac.jp',
                '/idp/profile/SAML2/Redirect/SSO',
                {
                  'execution': 'e1s3',
                },
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,',
                  'Cookie':
                      'JSESSIONID=$jsessionid; shib_idp_session=$shibidpsession',
                  'Referer':
                      'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s3',
                },
                validateStatus: (status) => status == 302,
              ),
              data:
                  'csrf_token=$csrftoken&_shib_idp_consentIds=displayName&_shib_idp_consentIds=eduPersonAffiliation&_shib_idp_consentIds=eduPersonEntitlement&_shib_idp_consentIds=eduPersonPrincipalName&_shib_idp_consentIds=eduPersonScopedAffiliation&_shib_idp_consentIds=eduPersonTargetedID&_shib_idp_consentIds=employeeNumber&_shib_idp_consentIds=givenName&_shib_idp_consentIds=jaDisplayName&_shib_idp_consentIds=jaGivenName&_shib_idp_consentIds=jaOrganizationName&_shib_idp_consentIds=jaSurname&_shib_idp_consentIds=jaorganizationalUnit&_shib_idp_consentIds=mail&_shib_idp_consentIds=organizationName&_shib_idp_consentIds=organizationalUnitName&_shib_idp_consentIds=surname&_shib_idp_consentIds=uid&_shib_idp_consentOptions=_shib_idp_globalConsent&_eventId_proceed=',
            );

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.getUri(
              Uri.https(
                'idp.shizuoka.ac.jp',
                '/idp/profile/SAML2/Redirect/SSO',
                {
                  'execution': 'e1s4',
                },
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,',
                  'Cookie':
                      'JSESSIONID=$jsessionid; shib_idp_session=$shibidpsession',
                  'Referer':
                      'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s3',
                },
              ),
            );

            csrftoken = null;
            csrftoken = RegExp(r'(?<=csrf_token" value=").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (csrftoken == null) {
              throw Exception('Failed to get csrf_token.');
            }

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'idp.shizuoka.ac.jp',
                '/idp/profile/SAML2/Redirect/SSO',
                {
                  'execution': 'e1s4',
                },
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,',
                  'Cookie':
                      'JSESSIONID=$jsessionid; shib_idp_session=$shibidpsession',
                  'Referer':
                      'https://idp.shizuoka.ac.jp/idp/profile/SAML2/Redirect/SSO?execution=e1s4',
                },
              ),
              data:
                  'csrf_token=$csrftoken&shib_idp_ls_exception.shib_idp_session_ss=&shib_idp_ls_success.shib_idp_session_ss=true&shib_idp_ls_exception.shib_idp_persistent_ss=&shib_idp_ls_success.shib_idp_persistent_ss=true&_eventId_proceed=',
            );

            var relaystate = RegExp(r'(?<=RelayState" value=").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (relaystate == null) {
              throw Exception('Failed to get RelayState.');
            }

            samlresponse = null;
            samlresponse = RegExp(r'(?<=SAMLResponse" value=").*?(?=")')
                .firstMatch(response.data.toString())
                ?.group(0);
            if (samlresponse == null) {
              throw Exception('Failed to get SAMLResponse.');
            }

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.postUri(
              Uri.https(
                'gakujo.shizuoka.ac.jp',
                '/Shibboleth.sso/SAML2/POST',
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,',
                  // 'Cookie':
                  // 'JSESSIONID=$jsessionid',
                  'Referer': 'https://idp.shizuoka.ac.jp/',
                },
                validateStatus: (status) => status == 302,
              ),
              data: {
                'RelayState': relaystate,
                'SAMLResponse': samlresponse,
              },
            );

            _setProgress(15 / 15);
            await Future.delayed(_interval);
            response = await _client.getUri(
              Uri.https(
                'gakujo.shizuoka.ac.jp',
                '/portal/shibbolethlogin/shibbolethLogin/initLogin/sso',
              ),
              options: Options(
                headers: {
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,',
                  // 'Cookie':
                  // 'JSESSIONID=$jsessionid',
                  'Referer': 'https://idp.shizuoka.ac.jp/',
                },
              ),
            );

            print(response.data);
          }
        }
      }
    }
  }

  Future<void> fetchContacts() async {
    _setProgress(0 / 2);
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

    _setProgress(1 / 2);
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
        'reportDateStart': await _reportDateStart
      },
    );
    _updateToken(response.data, required: true);

    _context?.read<ContactRepository>().addAll(parse(response.data)
        .querySelectorAll('#tbl_A01_01 > tbody > tr')
        .map(Contact.fromElement)
        .toList());
    _setProgress(2 / 2);
  }

  Future<Contact> fetchDetailContact(Contact contact,
      {bool bypass = false}) async {
    _setProgress(0 / 3);
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

      _setProgress(1 / 3);
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
            'reportDateStart': await _reportDateStart
          },
        ),
      );
      _updateToken(response.data, required: true);

      index = parse(response.data)
          .querySelectorAll('#tbl_A01_01 > tbody > tr')
          .map(Contact.fromElement)
          .toList()
          .indexOf(contact);
      if (index == -1) return contact;
    }

    _setProgress(2 / 3);
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
            'reportDateStart': await _reportDateStart,
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
    _context?.read<ContactRepository>().add(contact, overwrite: true);
    _setProgress(3 / 3);
    return contact;
  }

  Future<void> fetchSubjects() async {
    _setProgress(0 / 2);
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

    _setProgress(1 / 2);
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

    await _context?.read<SubjectRepository>().deleteAll();
    _context?.read<SubjectRepository>().addAll(parse(response.data)
        .querySelector('#st1')!
        .querySelectorAll('ul')
        .where((element) => element.querySelectorAll('li').length > 2)
        .map(Subject.fromElement)
        .toSet()
        .toList());
    _setProgress(2 / 2);
  }

  Future<void> fetchReports() async {
    _setProgress(0 / 2);
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

    _setProgress(1 / 2);
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

    _context?.read<ReportRepository>().addAll(parse(response.data)
        .querySelectorAll('#searchList > tbody > tr')
        .map(Report.fromElement)
        .toList());
    _setProgress(2 / 2);
  }

  Future<Report> fetchDetailReport(Report report, {bool bypass = false}) async {
    _setProgress(0 / 3);
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

      _setProgress(1 / 3);
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
          .isEmpty) return report;
    }

    _setProgress(2 / 3);
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
    _context?.read<ReportRepository>().add(report, overwrite: true);
    _setProgress(3 / 3);
    return report;
  }

  Future<void> fetchQuizzes() async {
    _setProgress(0 / 2);
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

    _setProgress(1 / 2);
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

    _context?.read<QuizRepository>().addAll(parse(response.data)
        .querySelectorAll('#searchList > tbody > tr')
        .map(Quiz.fromElement)
        .toList());
    _setProgress(2 / 2);
  }

  Future<Quiz> fetchDetailQuiz(Quiz quiz, {bool bypass = false}) async {
    _setProgress(0 / 3);
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

      _setProgress(1 / 3);
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
          .isEmpty) return quiz;
    }

    _setProgress(2 / 3);
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
    _context?.read<QuizRepository>().add(quiz, overwrite: true);
    _setProgress(3 / 3);
    return quiz;
  }

  Future<void> fetchSharedFiles() async {
    _setProgress(0 / 2);
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

    _setProgress(1 / 2);
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

    _context?.read<SharedFileRepository>().addAll(parse(response.data)
        .querySelectorAll('#tbl_classFile > tbody > tr')
        .map(SharedFile.fromElement)
        .toList());
    _setProgress(2 / 2);
  }

  Future<SharedFile> fetchDetailSharedFile(SharedFile sharedFile,
      {bool bypass = false}) async {
    _setProgress(0 / 3);
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

      _setProgress(1 / 3);
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
      if (index == -1) return sharedFile;
    }

    _setProgress(2 / 3);
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
    _context?.read<SharedFileRepository>().add(sharedFile, overwrite: true);
    _setProgress(3 / 3);
    return sharedFile;
  }

  Future<void> fetchClassLinks() async {
    _setProgress(0 / 2);
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

    _setProgress(1 / 2);
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

    _context?.read<ClassLinkRepository>().addAll(parse(response.data)
        .querySelectorAll('#tbl_classLinkList > tbody > tr')
        .map(ClassLink.fromElement)
        .toList());
    _setProgress(2 / 2);
  }

  Future<ClassLink> fetchDetailClassLink(ClassLink classLink,
      {bool bypass = false}) async {
    _setProgress(0 / 3);
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

      _setProgress(1 / 3);
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
          .isEmpty) return classLink;
    }

    _setProgress(2 / 3);
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
    _context?.read<ClassLinkRepository>().add(classLink, overwrite: true);
    _setProgress(3 / 3);
    return classLink;
  }

  Future<void> fetchQuestionnaires() async {
    _setProgress(0 / 2);
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/common/generalPurpose/',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'headTitle': '授業アンケート一覧',
        'menuCode': 'A05',
        'nextPath': '/classenq/student/searchList/initialize'
      },
    );
    _updateToken(response.data, required: true);

    _setProgress(1 / 2);
    await Future.delayed(_interval);
    response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/classenq/student/searchList/search',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'classEnqId': '',
        'hidSchoolYear': '',
        'hidSemesterCode': '',
        'hidSubjectCode': '',
        'hidClassCode': '',
        'backPath': '',
        'submitStatusCode': '',
        'entranceDiv': '',
        'listSchoolYear': '',
        'listSubjectCode': '',
        'listClassCode': '',
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'conditionMsg': '',
        'searchList_length': '-1',
      },
    );
    _updateToken(response.data, required: true);

    _context?.read<QuestionnaireRepository>().addAll(parse(response.data)
        .querySelectorAll('#searchList > tbody > tr')
        .map(Questionnaire.fromElement)
        .toList());
    _setProgress(2 / 2);
  }

  Future<Questionnaire> fetchDetailQuestionnaire(Questionnaire questionnaire,
      {bool bypass = false}) async {
    _setProgress(0 / 3);
    if (!bypass) {
      var response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/common/generalPurpose/',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'headTitle': '授業アンケート一覧',
          'menuCode': 'A05',
          'nextPath': '/classenq/student/searchList/initialize'
        },
      );
      _updateToken(response.data, required: true);

      _setProgress(1 / 3);
      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/portal/classenq/student/searchList/search',
        ),
        data: {
          'org.apache.struts.taglib.html.TOKEN': _token,
          'classEnqId': '',
          'hidSchoolYear': '',
          'hidSemesterCode': '',
          'hidSubjectCode': '',
          'hidClassCode': '',
          'backPath': '',
          'submitStatusCode': '',
          'entranceDiv': '',
          'listSchoolYear': '',
          'listSubjectCode': '',
          'listClassCode': '',
          'schoolYear': await _schoolYear,
          'semesterCode': await _semesterCode,
          'subjectDispCode': '',
          'conditionMsg': '',
          'searchList_length': '-1',
        },
      );
      _updateToken(response.data, required: true);

      if (parse(response.data)
          .querySelectorAll('#searchList > tbody > tr')
          .map(Questionnaire.fromElement)
          .where((e) => e == questionnaire)
          .isEmpty) return questionnaire;
    }

    _setProgress(2 / 3);
    await Future.delayed(_interval);
    var response = await _client.postUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/portal/classenq/student/searchList/countingResultReference',
      ),
      data: {
        'org.apache.struts.taglib.html.TOKEN': _token,
        'classEnqId': questionnaire.id,
        'hidSchoolYear': '',
        'hidSemesterCode': '',
        'hidSubjectCode': '',
        'hidClassCode': '',
        'backPath': '',
        'submitStatusCode': '',
        'entranceDiv': '',
        'listSchoolYear': await _schoolYear,
        'listSubjectCode': questionnaire.subjectCode,
        'listClassCode': questionnaire.classCode,
        'schoolYear': await _schoolYear,
        'semesterCode': await _semesterCode,
        'subjectDispCode': '',
        'conditionMsg': '',
        'searchList_length': '-1',
      },
    );
    _updateToken(response.data, required: true);
    var document = parse(response.data);
    questionnaire.fileNames = [];
    var dir = await getApplicationDocumentsDirectory();

    for (var node in document
        .querySelectorAll('table.ttb_entry > tbody > tr > td')[5]
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
          '/portal/classenq/fileDownload/temporaryFileDownload',
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
      questionnaire.fileNames?.add(basename(node.text.trim()));
    }

    questionnaire.toDetail(document);
    _context
        ?.read<QuestionnaireRepository>()
        .add(questionnaire, overwrite: true);
    _setProgress(3 / 3);
    return questionnaire;
  }

  Future<bool> fetchAcademicSystem({
    String? mainMenuCode,
    String? parentMenuCode,
  }) async {
    _setProgress(0 / 7);
    await _client.getUri<dynamic>(
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

    _setProgress(1 / 7);
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

    _setProgress(2 / 7);
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
      if (response.headers.value('location') == null) {
        throw Exception('Failed to get location header.');
      }

      _setProgress(3 / 7);
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

      if (samlResponse.isEmpty || relayState.isEmpty) {
        throw Exception('Failed to get SAMLResponse or RelayState.');
      }

      if (kDebugMode) {
        print('SAMLResponse: ${samlResponse.substring(0, 10)} ...');
        print('RelayState: ${relayState.substring(0, 10)} ...');
      }

      _setProgress(4 / 7);
      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
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

      if (response.headers.value('location') == null) {
        throw Exception('Failed to get location header.');
      }

      _setProgress(5 / 7);
      await Future.delayed(_interval);
      response = await _client.get<dynamic>(response.headers.value('location')!,
          options: Options(
            validateStatus: (status) => status == 302 || status == 200,
          ));

      if (response.statusCode == 302) {
        if (response.headers.value('location') == null) {
          throw Exception('Failed to get location header.');
        }

        _setProgress(6 / 7);
        await Future.delayed(_interval);
        response =
            await _client.get<dynamic>(response.headers.value('location')!);
      }
    }
    _setProgress(7 / 7);
    return mainMenuCode == null || parentMenuCode == null
        ? true
        : response.data.toString().contains(
              'mainMenuCode=$mainMenuCode&parentMenuCode=$parentMenuCode',
            );
  }

  Future<void> fetchGrades() async {
    if (!await fetchAcademicSystem(
        mainMenuCode: '008', parentMenuCode: '007')) {
      throw Exception('Failed due to out of validity period.');
    }

    _setProgress(0 / 5);
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
      await _context?.read<GradeRepository>().deleteAll();
      _context?.read<GradeRepository>().addAll(document
          .querySelector('table.txt12')!
          .querySelectorAll('tr')
          .skip(1)
          .map(Grade.fromElement)
          .toList());
    }

    Gpa gpa = await _context?.read<GpaRepository>().load() ?? Gpa.init();

    _setProgress(1 / 7);
    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/hyoukabetuTaniSearch.do',
      ),
    );
    document = parse(response.data);
    gpa.evaluationCredits = {};
    document
        .querySelectorAll('table.txt12')
        .first
        .querySelectorAll('tr')
        .forEach((e) {
      gpa.evaluationCredits[e.children[0].text.trimWhiteSpace()] =
          int.parse(e.children[1].text.trimWhiteSpace());
    });

    _setProgress(2 / 7);
    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/gpa.do',
      ),
    );
    document = parse(response.data);
    var rows =
        document.querySelectorAll('table.txt12').first.querySelectorAll('tr');
    gpa.facultyGrade = rows[0].children[1].text.trimWhiteSpace();
    gpa.facultyGpa = double.parse(rows[1].children[1].text.trimWhiteSpace());
    gpa.facultyGpas = {};
    rows.skip(2).toList().reversed.skip(3).forEach((e) {
      gpa.facultyGpas[e.children[0].text.trimWhiteSpace()] =
          double.parse(e.children[1].text.trimWhiteSpace());
    });
    gpa.facultyCalculationDate =
        rows.last.children[1].text.trimWhiteSpace().toDateTime();

    _setProgress(3 / 7);
    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/gpaImage.do',
      ),
      options: Options(responseType: ResponseType.bytes),
    );
    gpa.facultyImage = base64.encode(response.data);

    _setProgress(4 / 7);
    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/departmentGpa.do',
      ),
    );
    document = parse(response.data);
    rows =
        document.querySelectorAll('table.txt12').first.querySelectorAll('tr');
    gpa.departmentGrade = rows[0].children[1].text.trimWhiteSpace();
    gpa.departmentGpa = double.parse(rows[1].children[1].text.trimWhiteSpace());
    gpa.departmentGpas = {};
    rows.skip(2).toList().reversed.skip(3).forEach((e) {
      gpa.departmentGpas[e.children[0].text.trimWhiteSpace()] =
          double.parse(e.children[1].text.trimWhiteSpace());
    });
    gpa.departmentCalculationDate = rows.reversed
        .skip(2)
        .first
        .children[1]
        .text
        .trimWhiteSpace()
        .toDateTime();
    gpa.departmentRankNumber = int.parse(rows.reversed
        .toList()[1]
        .children[1]
        .text
        .trimWhiteSpace()
        .split('中')[1]
        .replaceAll('位', ''));
    gpa.departmentRankDenom = int.parse(rows.reversed
        .toList()[1]
        .children[1]
        .text
        .trimWhiteSpace()
        .split('中')[0]
        .replaceAll('人', ''));
    gpa.courseRankNumber = int.parse(rows.last.children[1].text
        .trimWhiteSpace()
        .split('中')[1]
        .replaceAll('位', ''));
    gpa.courseRankDenom = int.parse(rows.last.children[1].text
        .trimWhiteSpace()
        .split('中')[0]
        .replaceAll('人', ''));

    _setProgress(5 / 7);
    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/departmentGpaImage.do',
      ),
      options: Options(responseType: ResponseType.bytes),
    );
    gpa.departmentImage = base64.encode(response.data);

    _setProgress(6 / 7);
    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/nenbetuTaniSearch.do',
      ),
    );
    document = parse(response.data);
    gpa.evaluationCredits = {};
    document
        .querySelectorAll('table.txt12')
        .first
        .querySelectorAll('tr')
        .skip(1)
        .forEach((e) {
      gpa.yearCredits[e.children[0].text.trimWhiteSpace()] =
          int.parse(e.children[1].text.trimWhiteSpace());
    });

    await _context?.read<GpaRepository>().save(gpa);
    _setProgress(7 / 7);
  }

  Future<void> fetchTimetables() async {
    if (!await fetchAcademicSystem(
        mainMenuCode: '005', parentMenuCode: '004')) {
      throw Exception('Failed due to out of validity period.');
    }

    await Future.delayed(_interval);
    var response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/rishuuInit.do',
        {
          'mainMenuCode': '005',
          'parentMenuCode': '004',
        },
      ),
    );
    var document = parse(response.data);

    await _context?.read<TimetableRepository>().deleteAll();
    var table = document
        .querySelectorAll('table.txt12')[1]
        .querySelector('tbody')!
        .querySelectorAll('tr')
        .where((e) => e.attributes['bgcolor']?.toString() == "#FFFFFF")
        .toList();
    for (var i = 0; i < 6; i++) {
      for (var j = 1; j < 6; j++) {
        var cell = table[j]
            .querySelectorAll('td')
            .where((e) =>
                e.attributes['valign']?.toString() == "top" ||
                e.attributes['valign']?.toString() == "middle")
            .toList()[i];
        for (var node in cell.querySelectorAll('td.txt12')) {
          if (node.querySelector("a") != null) {
            if ((node.innerHtml
                        .contains("<font class=\"halfTime\">(前期前半)</font>") &&
                    semester != 0) ||
                (node.innerHtml
                        .contains("<font class=\"halfTime\">(前期後半)</font>") &&
                    semester != 1) ||
                ((node.innerHtml.contains(
                            "<font class=\"halfTime\">(後期前半)</font>") &&
                        semester != 2) ||
                    (node.innerHtml.contains(
                            "<font class=\"halfTime\">(後期後半)</font>") &&
                        semester != 3))) continue;
            var kamokuCode =
                node.querySelector("a")!.attributes["onclick"]!.trimJsArgs(1);
            var classCode =
                node.querySelector("a")!.attributes["onclick"]!.trimJsArgs(2);
            var classRoom = node.innerHtml.split('<br>').last.trimNewLines();
            Timetable timetable = await fetchDetailTimetable(
                i, j - 1, kamokuCode, classCode, classRoom);
            await _context?.read<TimetableRepository>().add(timetable);
          }
        }
      }
    }
  }

  Future<Timetable> fetchDetailTimetable(int weekday, int period,
      String kamokuCode, String classCode, String classRoom) async {
    Timetable timetable = Timetable.init();
    timetable.weekday = weekday;
    timetable.period = period;
    timetable.kamokuCode = kamokuCode;
    timetable.classCode = classCode;
    timetable.classRoom = classRoom;

    await Future.delayed(_interval);
    var response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/kyoumu/detailKamoku.do',
        {
          'detailKamokuCode': timetable.kamokuCode,
          'detailClassCode': timetable.classCode,
          'gamen': 'jikanwari',
        },
      ),
    );
    var document = parse(response.data);

    timetable.subject = document.trimTimetableValue('科目名');
    timetable.id = document.trimTimetableValue('科目番号');
    timetable.className = document.trimTimetableValue('クラス名');
    timetable.teacher = document.trimTimetableValue('担当教員');
    timetable.subjectSection = document.trimTimetableValue('科目区分');
    timetable.selectionSection = document.trimTimetableValue('必修選択区分');
    timetable.credit =
        int.parse(document.trimTimetableValue('単位数').replaceAll('単位', ''));

    await Future.delayed(_interval);
    response = await _client.getUri<dynamic>(
      Uri.https(
        'gakujo.shizuoka.ac.jp',
        '/syllabus2/rishuuSyllabusSearch.do',
        {
          'schoolYear': await _schoolYear,
          'subjectCD': timetable.id,
          'classCD': timetable.classCode,
        },
      ),
    );
    document = parse(response.data);

    if (!response.data.contains('シラバスの詳細は以下となります。')) {
      var subjectId =
          RegExp(r'(?<=subjectID=)\d*').firstMatch(response.data)?[0];
      var formatCd = RegExp(r'(?<=formatCD=)\d*').firstMatch(response.data)?[0];
      if (subjectId == null || formatCd == null) return timetable;

      await Future.delayed(_interval);
      response = await _client.getUri<dynamic>(
        Uri.https(
          'gakujo.shizuoka.ac.jp',
          '/syllabus2/rishuuSyllabusDetailEdit.do',
          {
            'subjectID': subjectId,
            'formatCD': formatCd,
            'rowIndex': '0',
            'jikanwariSchoolYear': await _schoolYear,
          },
        ),
      );
      document = parse(response.data);
    }

    timetable.syllabusSubject = document.trimSyllabusValue('授業科目名');
    timetable.syllabusTeacher = document.trimSyllabusValue('担当教員名');
    timetable.syllabusAffiliation = document.trimSyllabusValue('所属等');
    timetable.syllabusResearchRoom = document.trimSyllabusValue('研究室');
    timetable.syllabusSharingTeacher = document.trimSyllabusValue('分担教員名');
    timetable.syllabusClassName = document.trimSyllabusValue('クラス');
    timetable.syllabusSemesterName = document.trimSyllabusValue('学期');
    timetable.syllabusSelectionSection = document.trimSyllabusValue('必修選択区分');
    timetable.syllabusTargetGrade = document.trimSyllabusValue('対象学年');
    timetable.syllabusCredit = document.trimSyllabusValue('単位数');
    timetable.syllabusWeekdayPeriod = document.trimSyllabusValue('曜日・時限');
    timetable.syllabusClassRoom = document.trimSyllabusValue('教室');
    timetable.syllabusKeyword = document.trimSyllabusValue('キーワード');
    timetable.syllabusClassTarget = document.trimSyllabusValue('授業の目標');
    timetable.syllabusLearningDetail = document.trimSyllabusValue('学習内容');
    timetable.syllabusClassPlan = document.trimSyllabusValue('授業計画');
    timetable.syllabusClassRequirement = document.trimSyllabusValue('受講要件');
    timetable.syllabusTextbook = document.trimSyllabusValue('テキスト');
    timetable.syllabusReferenceBook = document.trimSyllabusValue('参考書');
    timetable.syllabusPreparationReview =
        document.trimSyllabusValue('予習・復習について');
    timetable.syllabusEvaluationMethod =
        document.trimSyllabusValue('成績評価の方法･基準');
    timetable.syllabusOfficeHour = document.trimSyllabusValue('オフィスアワー');
    timetable.syllabusMessage = document.trimSyllabusValue('担当教員からのメッセージ');
    timetable.syllabusActiveLearning =
        document.trimSyllabusValue('アクティブ・ラーニング');
    timetable.syllabusTeacherPracticalExperience =
        document.trimSyllabusValue('実務経験のある教員の有無');
    timetable.syllabusTeacherCareerClassDetail =
        document.trimSyllabusValue('実務経験のある教員の経歴と授業内容');
    timetable.syllabusTeachingProfessionSection =
        document.trimSyllabusValue('教職科目区分');
    timetable.syllabusRelatedClassSubjects =
        document.trimSyllabusValue('関連授業科目');
    timetable.syllabusOther = document.trimSyllabusValue('その他');
    timetable.syllabusHomeClassStyle = document.trimSyllabusValue('在宅授業形態');
    timetable.syllabusHomeClassStyleDetail =
        document.trimSyllabusValue('在宅授業形態（詳細）');
    return timetable;
  }
}
