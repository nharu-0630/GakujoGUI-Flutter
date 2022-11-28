import 'dart:convert';
import 'dart:typed_data';

import 'package:gakujo_task/api/parse.dart';
import 'package:html/dom.dart';

class Contact {
  String subjects;
  String teacherName;
  String contactType;
  String title;
  String? content;
  List<Uint8List>? fileBytes;
  List<String>? fileNames;
  String? fileLinkRelease;
  String? referenceUrl;
  String? severity;
  DateTime targetDateTime;
  DateTime contactDateTime;
  String? webReplyRequest;
  bool isAcquired;

  Contact(
      this.subjects,
      this.teacherName,
      this.contactType,
      this.title,
      this.content,
      this.fileBytes,
      this.fileNames,
      this.fileLinkRelease,
      this.referenceUrl,
      this.severity,
      this.targetDateTime,
      this.contactDateTime,
      this.webReplyRequest,
      {required this.isAcquired});

  static String encode(List<Contact> contacts) => json.encode(
        contacts.map<Map<String, dynamic>>(Contact.toJson).toList(),
      );

  static List<Contact> decode(String contacts) => json.decode(contacts) is List
      ? (json.decode(contacts) as List).map<Contact>(Contact.fromJson).toList()
      : [];

  factory Contact.fromJson(dynamic json) => Contact(
      json['subjects'] as String,
      json['teacherName'] as String,
      json['contactType'] as String,
      json['title'] as String,
      json['content'] as String?,
      (json['fileBytes'] as List<dynamic>?)
          ?.map((e) => base64Decode(e as String))
          .toList(),
      (json['fileNames'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['fileLinkRelease'] as String?,
      json['referenceUrl'] as String?,
      json['severity'] as String?,
      DateTime.parse(json['targetDateTime'] as String),
      DateTime.parse(json['contactDateTime'] as String),
      json['webReplyRequest'] as String?,
      isAcquired: json['isAcquired'] as bool);

  static Map<String, dynamic> toJson(Contact contact) => <String, dynamic>{
        'subjects': contact.subjects,
        'teacherName': contact.teacherName,
        'contactType': contact.contactType,
        'title': contact.title,
        'content': contact.content,
        'fileBytes': contact.fileBytes?.map(base64Encode).toList(),
        'fileNames': contact.fileNames,
        'fileLinkRelease': contact.fileLinkRelease,
        'referenceUrl': contact.referenceUrl,
        'severity': contact.severity,
        'targetDateTime': contact.targetDateTime.toIso8601String(),
        'contactDateTime': contact.contactDateTime.toIso8601String(),
        'webReplyRequest': contact.webReplyRequest,
        'isAcquired': contact.isAcquired,
      };

  factory Contact.fromElement(Element element) {
    return Contact(
      element.querySelectorAll('td')[1].text.trimWhiteSpace(),
      element.querySelectorAll('td')[2].text.trim(),
      element.querySelectorAll('td')[4].text.trim(),
      element.querySelectorAll('td')[3].querySelector('a')!.text.trim(),
      '',
      null,
      null,
      '',
      '',
      element
              .querySelectorAll('td')[3]
              .querySelector('span')
              ?.text
              .replaceFirst('【', '')
              .replaceFirst('】', '') ??
          '通常',
      element.querySelectorAll('td')[5].text.trim().trimDateTime(),
      element.querySelectorAll('td')[6].text.trim().trimDateTime(),
      '',
      isAcquired: false,
    );
  }

  void toDetail(Document document) {
    isAcquired = true;
    if (document.querySelectorAll('table.ttb_entry > tbody > tr > td').length >
        2) {
      content = document
          .querySelectorAll('table.ttb_entry > tbody > tr > td')[2]
          .text
          .trim();
    }
    if (document.querySelectorAll('table.ttb_entry > tbody > tr > td').length >
        8) {
      webReplyRequest = document
          .querySelectorAll('table.ttb_entry > tbody > tr > td')[8]
          .text
          .trim();
    }
  }
}
