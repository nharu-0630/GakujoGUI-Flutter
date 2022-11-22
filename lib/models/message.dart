import 'dart:convert';

import 'package:gakujo_task/api/parse.dart';
import 'package:html/dom.dart';

class Message {
  Message(
    this.subject,
    this.teacher,
    this.title,
    this.type,
    this.targetDateTime,
    this.contactDateTime,
    this.content,
    this.severity,
    this.webReplyRequest, {
    required this.isAcquired,
    required this.isArchived,
  });

  factory Message.fromJson(dynamic json) {
    json = json as Map<String, dynamic>;
    return Message(
      json['subject'] as String,
      json['teacher'] as String,
      json['title'] as String,
      json['type'] as String,
      (json['targetDateTime'] as String).parseDateTime(),
      (json['contactDateTime'] as String).parseDateTime(),
      json['content'] as String,
      json['severity'] as String,
      json['webReplyRequest'] as String,
      isAcquired: json['isAcquired'] as bool,
      isArchived: json['isArchived'] as bool,
    );
  }

  factory Message.fromElement(Element element) {
    final subject = element.querySelectorAll('td')[1].text.trimWhiteSpace();
    final teacher = element.querySelectorAll('td')[2].text.trim();
    final title =
        element.querySelectorAll('td')[3].querySelector('a')!.text.trim();
    final type = element.querySelectorAll('td')[4].text.trim();
    final targetDateTime =
        element.querySelectorAll('td')[5].text.trim().trimDateTime();
    final contactDateTime =
        element.querySelectorAll('td')[6].text.trim().trimDateTime();
    final severity = element
            .querySelectorAll('td')[3]
            .querySelector('span')
            ?.text
            .replaceFirst('【', '')
            .replaceFirst('】', '') ??
        '通常';
    return Message(
      subject,
      teacher,
      title,
      type,
      targetDateTime,
      contactDateTime,
      '',
      severity,
      '',
      isAcquired: false,
      isArchived: false,
    );
  }

  String subject = '';
  String teacher = '';
  String title = '';
  String type = '';
  DateTime targetDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  DateTime contactDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  String content = '';
  String severity = '通常';
  String webReplyRequest = '';
  bool isAcquired = false;
  bool isArchived = false;

  static Map<String, dynamic> toMap(Message contact) => <String, dynamic>{
        'subject': contact.subject,
        'teacher': contact.teacher,
        'title': contact.title,
        'type': contact.type,
        'targetDateTime': contact.targetDateTime.toIso8601String(),
        'contactDateTime': contact.contactDateTime.toIso8601String(),
        'content': contact.content,
        'severity': contact.severity,
        'webReplyRequest': contact.webReplyRequest,
        'isAcquired': contact.isAcquired,
        'isArchived': contact.isArchived,
      };

  static String encode(List<Message> contacts) => json.encode(
        contacts.map<Map<String, dynamic>>(Message.toMap).toList(),
      );

  static List<Message> decode(String contacts) => json.decode(contacts) is List
      ? (json.decode(contacts) as List).map<Message>(Message.fromJson).toList()
      : [];

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

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      title.toLowerCase().contains(value.toLowerCase()) ||
      content.toLowerCase().contains(value.toLowerCase());

  @override
  String toString() => '$subject $title';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Message) {
      return subject == other.subject &&
          title == other.title &&
          contactDateTime == other.contactDateTime;
    }
    return false;
  }

  @override
  int get hashCode =>
      subject.hashCode ^ title.hashCode ^ contactDateTime.hashCode;

  static List<Message> generateMessages() {
    return [
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('応用プログラミングA', '教員1', 'メッセージ1', '', DateTime.now(), DateTime.now(),
          'メッセージ1', '', '',
          isAcquired: false, isArchived: false),
      Message('人工知能概論', '教員2', 'メッセージ2', '', DateTime.now(), DateTime.now(),
          'メッセージ2', '', '',
          isAcquired: false, isArchived: false),
      Message('科目C', '教員3', 'メッセージ3', '', DateTime.now(), DateTime.now(),
          'メッセージ3', '', '',
          isAcquired: false, isArchived: false),
    ];
  }
}
