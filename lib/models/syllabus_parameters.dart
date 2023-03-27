import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';

class SyllabusParameters {
  Map<int, String> academicYearMap;
  Map<String, String> syllabusTitleIDMap;
  Map<String, String>? indexIDMap;
  Map<String, String> targetGradeMap;
  Map<String, String> semesterMap;
  Map<String, String> weekMap;
  Map<String, String> hourMap;

  SyllabusParameters({
    required this.academicYearMap,
    required this.syllabusTitleIDMap,
    this.indexIDMap,
    required this.targetGradeMap,
    required this.semesterMap,
    required this.weekMap,
    required this.hourMap,
  });

  factory SyllabusParameters.fromElement(
      String syllabusTitleID, Element element) {
    var academicYearMap = <int, String>{};
    academicYearMap.addEntries(element
        .querySelectorAll('tr')[0]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry<int, String>(
            int.parse(e.attributes['value'] ?? '-1'), e.text)));
    var syllabusTitleIDMap = <String, String>{};
    syllabusTitleIDMap.addEntries(element
        .querySelectorAll('tr')[1]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var indexIDMap = <String, String>{};
    indexIDMap.addEntries(element
        .querySelectorAll('tr')[2]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var targetGradeMap = <String, String>{};
    targetGradeMap.addEntries(element
        .querySelectorAll('tr')[3]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var semesterMap = <String, String>{};
    semesterMap.addEntries(element
        .querySelectorAll('tr')[4]
        .querySelector('select')!
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var weekMap = <String, String>{};
    weekMap.addEntries(element
        .querySelectorAll('tr')[5]
        .querySelectorAll('select')[0]
        .querySelectorAll('option')
        .skip(1)
        .map((e) => MapEntry(e.attributes['value'] ?? '-', e.text)));
    var hourMap = <String, String>{};
    hourMap.addEntries(element
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is SyllabusParameters) {
      return academicYearMap == other.academicYearMap &&
          mapEquals(syllabusTitleIDMap, other.syllabusTitleIDMap) &&
          mapEquals(indexIDMap, other.indexIDMap) &&
          mapEquals(targetGradeMap, other.targetGradeMap) &&
          mapEquals(semesterMap, other.semesterMap) &&
          mapEquals(weekMap, other.weekMap) &&
          mapEquals(hourMap, other.hourMap);
    }
    return false;
  }

  @override
  int get hashCode =>
      academicYearMap.hashCode ^
      syllabusTitleIDMap.hashCode ^
      indexIDMap.hashCode ^
      targetGradeMap.hashCode ^
      semesterMap.hashCode ^
      weekMap.hashCode ^
      hourMap.hashCode;
}
