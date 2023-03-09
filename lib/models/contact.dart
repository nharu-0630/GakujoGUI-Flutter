import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_task/api/parse.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact implements Comparable<Contact> {
  @HiveField(0)
  String subject;
  @HiveField(1)
  String teacherName;
  @HiveField(2)
  String contactType;
  @HiveField(3)
  String title;
  @HiveField(4)
  String content;
  @HiveField(5)
  List<String>? fileNames;
  @HiveField(6)
  String? fileLinkRelease;
  @HiveField(7)
  String? referenceUrl;
  @HiveField(8)
  String? severity;
  @HiveField(9)
  DateTime targetDateTime;
  @HiveField(10)
  DateTime contactDateTime;
  @HiveField(11)
  String? webReplyRequest;
  @HiveField(12)
  bool isAcquired;

  Contact(
      this.subject,
      this.teacherName,
      this.contactType,
      this.title,
      this.content,
      this.fileNames,
      this.fileLinkRelease,
      this.referenceUrl,
      this.severity,
      this.targetDateTime,
      this.contactDateTime,
      this.webReplyRequest,
      {required this.isAcquired});

  factory Contact.fromElement(Element element) {
    return Contact(
      element
          .querySelectorAll('td')[1]
          .text
          .trimWhiteSpace()
          .replaceAll(RegExp(r'（.*）(前|後)期.*'), ''),
      element.querySelectorAll('td')[2].text.trim(),
      element.querySelectorAll('td')[4].text.trim(),
      element.querySelectorAll('td')[3].querySelector('a')!.text.trim(),
      '',
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
      element.querySelectorAll('td')[5].text.trim().toDateTime(),
      element.querySelectorAll('td')[6].text.trim().toDateTime(),
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
        4) {
      fileLinkRelease = document
          .querySelectorAll('table.ttb_entry > tbody > tr > td')[4]
          .text
          .trim();
    }
    if (document.querySelectorAll('table.ttb_entry > tbody > tr > td').length >
        5) {
      referenceUrl = document
          .querySelectorAll('table.ttb_entry > tbody > tr > td')[5]
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
      (content).toLowerCase().contains(value.toLowerCase());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Contact) {
      return subject == other.subject &&
          title == other.title &&
          contactDateTime == other.contactDateTime;
    }
    return false;
  }

  @override
  int get hashCode =>
      subject.hashCode ^ title.hashCode ^ contactDateTime.hashCode;

  @override
  int compareTo(Contact other) {
    var compare1 = contactDateTime.compareTo(other.contactDateTime);
    if (compare1 != 0) {
      return compare1;
    }
    var compare2 = subject.compareTo(other.subject);
    if (compare2 != 0) {
      return compare2;
    }
    var compare3 = title.compareTo(other.title);
    return compare3;
  }
}

class ContactBox {
  Future<Box> box = Hive.openBox<Contact>('contact');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<Contact>('contact');
    }
  }
}

class ContactRepository extends ChangeNotifier {
  late ContactBox _contactBox;

  ContactRepository(ContactBox contactBox) {
    _contactBox = contactBox;
  }

  Future<void> add(Contact contact, {bool overwrite = false}) async {
    var box = await _contactBox.box;
    if (!overwrite && box.containsKey(contact.hashCode)) return;
    await box.put(contact.hashCode, contact);
    notifyListeners();
  }

  Future<void> addAll(List<Contact> contacts, {bool overwrite = false}) async {
    for (var contact in contacts) {
      await add(contact, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(Contact contact) async {
    var box = await _contactBox.box;
    await box.delete(contact.hashCode);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _contactBox.box;
    await box.deleteFromDisk();
    await _contactBox.open();
    notifyListeners();
  }

  Future<Contact?> get(int key) async {
    var box = await _contactBox.box;
    return box.get(key);
  }

  Future<List<Contact>> getAll() async {
    var box = await _contactBox.box;
    return box.values.toList().cast<Contact>();
  }

  Future<List<Contact>> getSubjects(String subject) async {
    var box = await _contactBox.box;
    return box.values
        .where((contact) => contact.subjects == subject)
        .toList()
        .cast<Contact>();
  }
}
