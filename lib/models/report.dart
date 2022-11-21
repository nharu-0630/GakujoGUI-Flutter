import 'dart:convert';

import 'package:flutter/material.dart' show Icons;
import 'package:gakujo_task/api/parse.dart';
import 'package:gakujo_task/constants/colors.dart';
import 'package:gakujo_task/models/task.dart';
import 'package:html/dom.dart';

class Report implements Comparable<Report> {
  Report(
    this.subject,
    this.title,
    this.id,
    this.schoolYear,
    this.subjectCode,
    this.classCode,
    this.status,
    this.startDateTime,
    this.endDateTime,
    this.implementationFormat,
    this.operation,
    this.submittedDateTime,
    this.evaluationMethod,
    this.description,
    this.message, {
    required this.isAcquired,
    required this.isArchived,
  });

  factory Report.fromJson(dynamic json) {
    json = json as Map<String, dynamic>;
    return Report(
      json['subject'] as String,
      json['title'] as String,
      json['id'] as String,
      json['schoolYear'] as String,
      json['subjectCode'] as String,
      json['classCode'] as String,
      json['status'] as String,
      (json['startDateTime'] as String).parseDateTime(),
      (json['endDateTime'] as String).parseDateTime(),
      json['implementationFormat'] as String,
      json['operation'] as String,
      (json['submittedDateTime'] as String).parseDateTime(),
      json['evaluationMethod'] as String,
      json['description'] as String,
      json['message'] as String,
      isAcquired: json['isAcquired'] as bool,
      isArchived: json['isArchived'] as bool,
    );
  }

  factory Report.fromDocument(String subject, Document document) {
    final title =
        document.querySelector('#area > table > tbody > tr > td')?.text ?? '';
    final id = document
            .querySelector(
              '#right-box > form > input[type=hidden]:nth-child(2)',
            )
            ?.attributes['value'] ??
        '';
    final startDateTime = document
        .querySelector('#area > table > tbody > tr:nth-child(1) > td')!
        .text
        .trimSpanDateTime(0);
    final endDateTime = document
        .querySelector('#area > table > tbody > tr:nth-child(1) > td')!
        .text
        .trimSpanDateTime(1);
    final submittedDateTime = document
            .querySelector(
              '''
#area > div > table > tbody > tr > td > table > tbody > tr > td > label''',
            )
            ?.text
            .replaceAll(RegExp(r'.*comment by .*? '), '')
            .parseDateTime() ??
        DateTime.fromMicrosecondsSinceEpoch(0);
    final report = Report(
      subject.trimSubject(),
      title,
      id,
      '',
      '',
      '',
      '',
      startDateTime,
      endDateTime,
      '',
      '',
      submittedDateTime,
      '',
      '',
      '',
      isAcquired: false,
      isArchived: false,
    )..toDetail(document);
    return report;
  }

  factory Report.fromElement(Element element) {
    final subject =
        element.querySelectorAll('td')[0].text.trimWhiteSpace().trimSubject();
    final title =
        element.querySelectorAll('td')[1].querySelector('a')!.text.trim();
    final id = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(1);
    final schoolYear = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(3);
    final subjectCode = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(4);
    final classCode = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(5);
    final status = element.querySelectorAll('td')[2].text.trim();
    final startDateTime =
        element.querySelectorAll('td')[3].text.trimSpanDateTime(0);
    final endDateTime =
        element.querySelectorAll('td')[3].text.trimSpanDateTime(1);
    final implementationFormat = element.querySelectorAll('td')[5].text.trim();
    final operation = element.querySelectorAll('td')[6].text.trim();
    var submittedDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
    if (element.querySelectorAll('td')[4].text != '') {
      submittedDateTime =
          element.querySelectorAll('td')[4].text.trim().trimDateTime();
    }
    return Report(
      subject,
      title,
      id,
      schoolYear,
      subjectCode,
      classCode,
      status,
      startDateTime,
      endDateTime,
      implementationFormat,
      operation,
      submittedDateTime,
      '',
      '',
      '',
      isAcquired: false,
      isArchived: false,
    );
  }

  String subject = '';
  String title = '';
  String id = '';
  String schoolYear = '';
  String subjectCode = '';
  String classCode = '';
  String status = '';
  DateTime startDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  DateTime endDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  String implementationFormat = '';
  String operation = '';
  DateTime submittedDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  String evaluationMethod = '';
  String description = '';
  String message = '';
  bool isAcquired = false;
  bool isArchived = false;

  static Map<String, dynamic> toMap(Report report) => <String, dynamic>{
        'subject': report.subject,
        'title': report.title,
        'id': report.id,
        'schoolYear': report.schoolYear,
        'subjectCode': report.subjectCode,
        'classCode': report.classCode,
        'status': report.status,
        'startDateTime': report.startDateTime.toIso8601String(),
        'endDateTime': report.endDateTime.toIso8601String(),
        'implementationFormat': report.implementationFormat,
        'operation': report.operation,
        'submittedDateTime': report.submittedDateTime.toIso8601String(),
        'evaluationMethod': report.evaluationMethod,
        'description': report.description,
        'message': report.message,
        'isAcquired': report.isAcquired,
        'isArchived': report.isArchived
      };

  static String encode(List<Report> reports) => json.encode(
        reports.map<Map<String, dynamic>>(Report.toMap).toList(),
      );

  static List<Report> decode(String reports) => json.decode(reports) is List
      ? (json.decode(reports) as List).map<Report>(Report.fromJson).toList()
      : [];

  bool get isSubmitted =>
      submittedDateTime != DateTime.fromMicrosecondsSinceEpoch(0);

  void toRefresh(Report report) {
    title = report.title;
    status = report.status;
    startDateTime = report.startDateTime;
    endDateTime = report.endDateTime;
    submittedDateTime = report.submittedDateTime;
    implementationFormat = report.implementationFormat;
    operation = report.operation;
  }

  void toDetail(Document document) {
    isAcquired = true;
    evaluationMethod = document
            .querySelector('#area > table > tbody > tr:nth-child(2) > td')
            ?.text ??
        '';
    description = document
            .querySelector('#area > table > tbody > tr:nth-child(3) > td')
            ?.text ??
        '';
    message = document
            .querySelector('#area > table > tbody > tr:nth-child(5) > td')
            ?.text ??
        '';
  }

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      title.toLowerCase().contains(value.toLowerCase()) ||
      description.toLowerCase().contains(value.toLowerCase()) ||
      message.toLowerCase().contains(value.toLowerCase());

  @override
  String toString() => '[$status] $subject $title -> $endDateTime';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Report) {
      return subjectCode == other.subjectCode &&
          classCode == other.classCode &&
          id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => subjectCode.hashCode ^ classCode.hashCode ^ id.hashCode;

  @override
  int compareTo(Report other) {
    final compare1 = endDateTime.compareTo(other.endDateTime) * -1;
    if (compare1 != 0) {
      return compare1;
    }
    final compare2 = startDateTime.compareTo(other.startDateTime) * -1;
    if (compare2 != 0) {
      return compare2;
    }
    final compare3 = subjectCode.compareTo(other.subjectCode);
    if (compare3 != 0) {
      return compare3;
    }
    final compare4 = id.compareTo(other.id);
    return compare4;
  }

  static Task toTask(List<Report> reports) => Task(
      iconData: Icons.text_snippet_rounded,
      title: 'レポート',
      bgColor: kYellowLight,
      iconColor: kYellowDark,
      btnColor: kYellow,
      left: reports
          .where((e) => !e.isSubmitted && e.endDateTime.isAfter(DateTime.now()))
          .length,
      done: reports.where((e) => e.isSubmitted).length,
      desc: reports
          .map((e) => {
                'time': e.endDateTime,
                'title': e.title,
                'slot': e.subject,
                'tlColor': kYellowDark,
                'bgColor': kYellowLight,
              })
          .toList());
}
