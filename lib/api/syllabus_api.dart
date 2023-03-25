import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/models/syllabus_detail.dart';
import 'package:gakujo_gui/models/syllabus_parameters.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:html/dom.dart';
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
    var academicYearMap = <int, String>{};
    academicYearMap.addEntries(document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')[0]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry<int, String>(
            int.parse(e.attributes['value'] ?? '-1'), e.text)));
    var syllabusTitleIDMap = <String, String>{};
    syllabusTitleIDMap.addEntries(document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')[1]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var indexIDMap = <String, String>{};
    indexIDMap.addEntries(document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')[2]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var targetGradeMap = <String, String>{};
    targetGradeMap.addEntries(document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')[3]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var semesterMap = <String, String>{};
    semesterMap.addEntries(document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')[4]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var weekMap = <String, String>{};
    weekMap.addEntries(document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')[5]
        .querySelectorAll('select')[0]
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var hourMap = <String, String>{};
    hourMap.addEntries(document
        .querySelector('table.txt12')!
        .querySelectorAll('tr')[5]
        .querySelectorAll('select')[1]
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));

    return SyllabusParameters(
      academicYearMap: academicYearMap,
      syllabusTitleIDMap: syllabusTitleIDMap,
      indexIDMap: syllabusTitleID.isNotEmpty ? indexIDMap : null,
      targetGradeMap: targetGradeMap,
      semesterMap: semesterMap,
      weekMap: weekMap,
      hourMap: hourMap,
    );
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

    if (response.data.contains('検索条件に合致する科目が見つかりません。')) {
      return [];
    }

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
      subject: trimSyllabusValue(document, '授業科目名', offset: 2),
      teacher: trimSyllabusValue(document, '担当教員名'),
      affiliation: trimSyllabusValue(document, '所属等'),
      researchRoom: trimSyllabusValue(document, '研究室'),
      sharingTeacher: trimSyllabusValue(document, '分担教員名'),
      className: trimSyllabusValue(document, 'クラス'),
      semesterName: trimSyllabusValue(document, '学期'),
      selectionSection: trimSyllabusValue(document, '必修選択区分'),
      targetGrade: trimSyllabusValue(document, '対象学年'),
      credit: trimSyllabusValue(document, '単位数'),
      weekdayPeriod: trimSyllabusValue(document, '曜日・時限'),
      classRoom: trimSyllabusValue(document, '教室'),
      keyword: trimSyllabusValue(document, 'キーワード'),
      classTarget: trimSyllabusValue(document, '授業の目標'),
      learningDetail: trimSyllabusValue(document, '学習内容'),
      classPlan: trimSyllabusValue(document, '授業計画'),
      classRequirement: trimSyllabusValue(document, '受講要件'),
      textbook: trimSyllabusValue(document, 'テキスト'),
      referenceBook: trimSyllabusValue(document, '参考書'),
      preparationReview: trimSyllabusValue(document, '予習・復習について'),
      evaluationMethod: trimSyllabusValue(document, '成績評価の方法･基準'),
      officeHour: trimSyllabusValue(document, 'オフィスアワー'),
      message: trimSyllabusValue(document, '担当教員からのメッセージ'),
      activeLearning: trimSyllabusValue(document, 'アクティブ・ラーニング'),
      teacherPracticalExperience: trimSyllabusValue(document, '実務経験のある教員の有無'),
      teacherCareerClassDetail:
          trimSyllabusValue(document, '実務経験のある教員の経歴と授業内容'),
      teachingProfessionSection: trimSyllabusValue(document, '教職科目区分'),
      relatedClassSubjects: trimSyllabusValue(document, '関連授業科目'),
      other: trimSyllabusValue(document, 'その他'),
      homeClassStyle: trimSyllabusValue(document, '在宅授業形態'),
      homeClassStyleDetail: trimSyllabusValue(document, '在宅授業形態（詳細）'),
    );
    return syllabus;
  }

  String trimSyllabusValue(Document document, String key, {int offset = 1}) {
    var cells = document.querySelectorAll('td');
    var index = cells.indexWhere(
        (e) => e.querySelector('font')?.text.contains(key) ?? false);
    return cells[index + offset].text.trimWhiteSpace();
  }
}
