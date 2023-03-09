import 'dart:convert';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';

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

  DateTime trimSpanDateTime(int index) =>
      DateFormat('y/M/d HH:mm').parse(trim().split('～')[index].trim());

  DateTime trimDateTime() {
    try {
      return DateFormat('y/M/d').parse(this);
    } on FormatException {
      try {
        return DateFormat('y/M/d HH:mm').parse(this);
      } on FormatException {
        try {
          return DateFormat('y年 MM月 dd日').parse(this);
        } on FormatException {
          return DateTime.fromMicrosecondsSinceEpoch(0);
        }
      }
    }
  }

  String trimNewLines() => HtmlUnescape()
      .convert(this)
      .replaceAll('<br>', ' \r\n')
      .trim()
      .replaceAll(RegExp(r'[\r\n]+', multiLine: true), '\r\n')
      .trim();

  Color parseColor() {
    var bytes = md5.convert(utf8.encode(this));
    return Color(int.parse('0xFF${bytes.toString().substring(0, 6)}'));
  }
}
