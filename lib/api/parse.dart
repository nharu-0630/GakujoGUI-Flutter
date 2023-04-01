import 'dart:convert';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeParsing on DateTime {
  String toDateTimeString() =>
      DateFormat('yyyy/MM/dd HH:mm', 'ja').format(this);

  String toDateString() => DateFormat('yyyy/MM/dd', 'ja').format(this);

  String toAgoString() => timeago.format(this, locale: 'ja');
}

extension DocumentParsing on Document {
  String trimSyllabusValue(String key, {int offset = 1}) {
    var cells = querySelectorAll('td');
    var index = cells.indexWhere(
        (e) => e.querySelector('font')?.text.contains(key) ?? false);
    return cells[index + offset].text.trimWhiteSpace();
  }

  String trimTimetableValue(String key) {
    var cells = querySelector('table.txt12')!.querySelectorAll('td');
    var index = cells.indexWhere((e) => e.text.contains(key));
    return cells[index + 1].text.trimWhiteSpace();
  }
}

extension StringParsing on String {
  String trimWhiteSpace() => replaceAll('\r', '')
      .replaceAll('\n', '')
      .replaceAll('\t', '')
      .replaceAll('&nbsp;', '')
      .trim()
      .replaceAll(r'\s+', '')
      .replaceAll(RegExp(r' +'), '');

  String trimSubject() => replaceAll(RegExp(r'(\(|（).*'), '');

  String trimJsArgs(int index) => split(',')[index]
      .replaceAll('\'', '')
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll(';', '')
      .trim();

  String trimNewLines() => HtmlUnescape()
      .convert(this)
      .replaceAll('<br>', ' \r\n')
      .trim()
      .replaceAll(RegExp(r'[\r\n]+', multiLine: true), '\r\n')
      .trim();

  DateTime toSpanDateTime(int index) =>
      DateFormat('y/M/d HH:mm').parse(trim().split('～')[index].trim());

  DateTime toDateTime() {
    try {
      return DateFormat('y/M/d HH:mm').parse(this);
    } on FormatException {
      try {
        return DateFormat('y/M/d').parse(this);
      } on FormatException {
        try {
          return DateFormat('y年 MM月 dd日').parse(this);
        } on FormatException {
          return DateTime.fromMicrosecondsSinceEpoch(0);
        }
      }
    }
  }

  Color toColor() {
    var bytes = md5.convert(utf8.encode(this));
    return Color(int.parse('0xFF${bytes.toString().substring(0, 6)}'));
  }
}
