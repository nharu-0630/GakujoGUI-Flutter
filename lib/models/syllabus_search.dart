class SyllabusSearch {
  Map<int, String> academicYearMap;
  Map<String, String> syllabusTitleIDMap;
  Map<String, String>? indexIDMap;
  Map<String, String> targetGradeMap;
  Map<String, String> semesterMap;
  Map<String, String> weekMap;
  Map<String, String> hourMap;

  SyllabusSearch({
    required this.academicYearMap,
    required this.syllabusTitleIDMap,
    this.indexIDMap,
    required this.targetGradeMap,
    required this.semesterMap,
    required this.weekMap,
    required this.hourMap,
  });
}
