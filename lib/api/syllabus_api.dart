import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/models/syllabus_detail.dart';
import 'package:gakujo_gui/models/syllabus_parameters.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:html/parser.dart';
import 'package:version/version.dart';

class SyllabusApi {
  static final version = Version(1, 0, 0);
  static final userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36 SyllabusAPI/$version';
  static const _interval = Duration(milliseconds: 250);

  late Dio _client;
  late CookieJar _cookieJar;
  String? _idpSession;

  Future<void> _initialize() async {
    _client = Dio(BaseOptions(
      headers: {
        'User-Agent': userAgent,
      },
      contentType: Headers.formUrlEncodedContentType,
      followRedirects: false,
    ));
    _cookieJar = CookieJar();
    _idpSession = null;
    _client.interceptors.add(CookieManager(_cookieJar));
    _client.interceptors.add(LogInterceptor());
  }

  Future<SyllabusParameters> fetchSyllabusParameters(
      String syllabusTitleID) async {
    dynamic response;
    if (syllabusTitleID.isEmpty) {
      await _initialize();

      response = await _client.getUri<dynamic>(
        Uri.https('syllabus.shizuoka.ac.jp',
            '/ext_syllabus/syllabusSearchDirect.do', {'nologin': 'on'}),
      );

      if (response.headers.value('set-cookie') != null) {
        _idpSession = RegExp(r'(?<=JSESSIONID=).*?(?=;)')
            .firstMatch(response.headers.value('set-cookie')!)
            ?.group(0);
      }

      if (_idpSession == null) {
        throw Exception('Failed to get IdPSession.');
      }
    }

    if (syllabusTitleID.isNotEmpty) {
      await Future.delayed(_interval);
      response = await _client.postUri<dynamic>(
        Uri.https('syllabus.shizuoka.ac.jp', '/ext_syllabus/syllabusSearch.do'),
        data: {
          'academicYear': '',
          'syllabusTitleID': syllabusTitleID,
          'indexID': '',
          'subFolderFlag': 'on',
          'targetGrade': '',
          'semester': '',
          'week': '',
          'hour': '',
          'kamokuName': '',
          'editorName': '',
          'numberingAtrib': '',
          'numberingLevel': '',
          'numberingSubjectType': '',
          'numberingAcademic': '',
          'freeWord': '',
          'actionStatus': 'titleID',
          'subFolderFlag2': 'on',
          'bottonType': 'titleID',
        },
        options: Options(
          headers: {
            'Cookie': 'JSESSIONID=$_idpSession',
          },
        ),
      );
    }

    var document = parse(response.data);
    return SyllabusParameters.fromElement(
        syllabusTitleID, document.querySelector('table.txt12')!);
  }

  Future<List<SyllabusResult>> fetchSyllabusResult({
    required String academicYear,
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
    var response = await _client.postUri<dynamic>(
      Uri.https('syllabus.shizuoka.ac.jp', '/ext_syllabus/syllabusSearch.do'),
      data: {
        'academicYear': academicYear,
        'syllabusTitleID': syllabusTitleID,
        'indexID': indexID,
        'subFolderFlag': 'on',
        'targetGrade': targetGrade,
        'semester': semester,
        'halfTimeInfo': '',
        'week': week,
        'hour': hour,
        'kamokuName': kamokuName,
        'editorName': editorName,
        'numberingAtrib': '',
        'numberingLevel': '',
        'numberingSubjectType': '',
        'numberingAcademic': '',
        'freeWord': freeWord,
        'actionStatus': 'search',
        'subFolderFlag2': 'on',
        'bottonType': 'search',
      },
      options: Options(
        headers: {
          'Cookie': 'JSESSIONID=$_idpSession',
        },
      ),
    );

    if (response.data.contains('検索条件に合致する科目が見つかりません。')) return [];
    if (response.data.contains('のいずれかを入力してください。')) return [];
    var document = parse(response.data);
    return document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')
        .skip(1)
        .map((e) => SyllabusResult.fromElement(e))
        .toList();
  }

  Future<SyllabusDetail> fetchSyllabusDetail(SyllabusResult query) async {
    var response = await _client.postUri<dynamic>(
      Uri.https('syllabus.shizuoka.ac.jp',
          '/ext_syllabus/syllabusReferenceContentsInit.do'),
      data: {
        'subjectId': query.subjectId,
        'formatCode': query.formatCode,
        'rowIndex': query.rowIndex,
        'jikanwariSchoolYear': query.jikanwariSchoolYear,
      },
      options: Options(
        headers: {
          'Cookie': 'JSESSIONID=$_idpSession',
        },
      ),
    );

    var document = parse(response.data);
    var syllabus = SyllabusDetail(
      subject: document.trimSyllabusValue('授業科目名', offset: 2),
      teacher: document.trimSyllabusValue('担当教員名'),
      affiliation: document.trimSyllabusValue('所属等'),
      researchRoom: document.trimSyllabusValue('研究室'),
      sharingTeacher: document.trimSyllabusValue('分担教員名'),
      className: document.trimSyllabusValue('クラス'),
      semesterName: document.trimSyllabusValue('学期'),
      selectionSection: document.trimSyllabusValue('必修選択区分'),
      targetGrade: document.trimSyllabusValue('対象学年'),
      credit: document.trimSyllabusValue('単位数'),
      weekdayPeriod: document.trimSyllabusValue('曜日・時限'),
      classRoom: document.trimSyllabusValue('教室'),
      keyword: document.trimSyllabusValue('キーワード'),
      classTarget: document.trimSyllabusValue('授業の目標'),
      learningDetail: document.trimSyllabusValue('学習内容'),
      classPlan: document.trimSyllabusValue('授業計画'),
      classRequirement: document.trimSyllabusValue('受講要件'),
      textbook: document.trimSyllabusValue('テキスト'),
      referenceBook: document.trimSyllabusValue('参考書'),
      preparationReview: document.trimSyllabusValue('予習・復習について'),
      evaluationMethod: document.trimSyllabusValue('成績評価の方法･基準'),
      officeHour: document.trimSyllabusValue('オフィスアワー'),
      message: document.trimSyllabusValue('担当教員からのメッセージ'),
      activeLearning: document.trimSyllabusValue('アクティブ・ラーニング'),
      teacherPracticalExperience: document.trimSyllabusValue('実務経験のある教員の有無'),
      teacherCareerClassDetail: document.trimSyllabusValue('実務経験のある教員の経歴と授業内容'),
      teachingProfessionSection: document.trimSyllabusValue('教職科目区分'),
      relatedClassSubjects: document.trimSyllabusValue('関連授業科目'),
      other: document.trimSyllabusValue('その他'),
      homeClassStyle: document.trimSyllabusValue('在宅授業形態'),
      homeClassStyleDetail: document.trimSyllabusValue('在宅授業形態（詳細）'),
    );
    return syllabus;
  }
}
