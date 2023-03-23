import 'dart:convert';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';

extension DateTimeParsing on DateTime {
  String toDetailString() => DateFormat('yyyy/MM/dd HH:mm', 'ja').format(this);

  String toDateString() => DateFormat('yyyy/MM/dd', 'ja').format(this);
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
