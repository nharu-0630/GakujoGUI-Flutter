import 'package:gakujo_gui/api/parse.dart';
import 'package:html/dom.dart';

class SyllabusResult {
  String subjectId;
  String titleName;
  String indexName;
  String subjectCode;
  String numberingCode;
  String subjectName;
  String language;
  String teacherName;
  String className;
  String halfTimeInfo;
  String youbiJigen;

  SyllabusResult({
    required this.subjectId,
    required this.titleName,
    required this.indexName,
    required this.subjectCode,
    required this.numberingCode,
    required this.subjectName,
    required this.language,
    required this.teacherName,
    required this.className,
    required this.halfTimeInfo,
    required this.youbiJigen,
  });

  factory SyllabusResult.fromElement(Element element) {
    return SyllabusResult(
      subjectId: RegExp(r'(?<=subjectId=)\d*').firstMatch(
          element.querySelectorAll('td')[0].attributes['onclick']!)![0]!,
      titleName: element.querySelectorAll('td')[0].text.trimWhiteSpace(),
      indexName: element.querySelectorAll('td')[1].text.trimWhiteSpace(),
      subjectCode: element.querySelectorAll('td')[2].text.trimWhiteSpace(),
      numberingCode: element.querySelectorAll('td')[3].text.trimWhiteSpace(),
      subjectName: element.querySelectorAll('td')[4].text.trimWhiteSpace(),
      language: element.querySelectorAll('td')[5].text.trimWhiteSpace(),
      teacherName: element.querySelectorAll('td')[6].text.trimWhiteSpace(),
      className: element.querySelectorAll('td')[7].text.trimWhiteSpace(),
      halfTimeInfo: element.querySelectorAll('td')[8].text.trimWhiteSpace(),
      youbiJigen: element.querySelectorAll('td')[9].text.trimWhiteSpace(),
    );
  }
}
