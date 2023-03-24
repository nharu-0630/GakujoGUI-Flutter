class SyllabusSearch {
  Map<int, String> academicYearMap;
  Map<String, String> syllabusTitleIDMap;
  Map<String, String>? indexIDMap;

  SyllabusSearch({
    required this.academicYearMap,
    required this.syllabusTitleIDMap,
    this.indexIDMap,
  });
}
