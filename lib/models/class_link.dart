import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_gui/api/parse.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'class_link.g.dart';

@HiveType(typeId: 8)
class ClassLink implements Comparable<ClassLink> {
  @HiveField(0)
  String subject;
  @HiveField(1)
  String title;
  @HiveField(2)
  String id;
  @HiveField(3)
  String comment;
  @HiveField(4)
  String link;
  @HiveField(5)
  bool isAcquired = false;
  @HiveField(6)
  bool isArchived = false;

  ClassLink({
    required this.subject,
    required this.title,
    required this.id,
    required this.comment,
    required this.link,
    required this.isAcquired,
    required this.isArchived,
  });

  factory ClassLink.fromElement(Element element) {
    return ClassLink(
      subject:
          element.querySelectorAll('td')[1].text.trimWhiteSpace().trimSubject(),
      title: element.querySelectorAll('td')[2].querySelector('a')!.text.trim(),
      id: element
          .querySelectorAll('td')[2]
          .querySelector('a')!
          .attributes['onclick']!
          .trimJsArgs(0)
          .replaceAll('javascript:moveToDetail', ''),
      comment: element.querySelectorAll('td')[3].text.trim(),
      link: '',
      isAcquired: false,
      isArchived: false,
    );
  }

  void toDetail(Document document) {
    isAcquired = true;
    link = document
        .querySelectorAll('table.ttb_entry > tbody > tr > td')[1]
        .querySelector('a')!
        .attributes['href']!;
  }

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      title.toLowerCase().contains(value.toLowerCase()) ||
      comment.toLowerCase().contains(value.toLowerCase());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ClassLink) {
      return subject == other.subject && title == other.title;
    }
    return false;
  }

  @override
  int get hashCode => subject.hashCode ^ title.hashCode ^ id.hashCode;

  @override
  int compareTo(ClassLink other) {
    var compare1 = subject.compareTo(other.subject);
    if (compare1 != 0) return compare1;
    var compare2 = title.compareTo(other.title);
    if (compare2 != 0) return compare2;
    var compare3 = id.compareTo(other.id);
    return compare3;
  }
}

class ClassLinkBox {
  Future<Box> box = Hive.openBox<ClassLink>('class_link');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<ClassLink>('class_link');
    }
  }
}

class ClassLinkRepository extends ChangeNotifier {
  late ClassLinkBox _box;

  ClassLinkRepository(ClassLinkBox box) {
    _box = box;
  }

  Future<void> add(ClassLink classLink, {bool overwrite = false}) async {
    var box = await _box.box;
    if (!overwrite && box.containsKey(classLink.id)) return;
    await box.put(classLink.id, classLink);
    notifyListeners();
  }

  Future<void> addAll(List<ClassLink> classLinks,
      {bool overwrite = false}) async {
    for (var classLink in classLinks) {
      await add(classLink, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(ClassLink classLink) async {
    var box = await _box.box;
    await box.delete(classLink.id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _box.box;
    await box.deleteFromDisk();
    await _box.open();
    notifyListeners();
  }

  Future<ClassLink?> get(int key) async {
    var box = await _box.box;
    return box.get(key);
  }

  Future<List<ClassLink>> getAll() async {
    var box = await _box.box;
    return box.values.toList().cast<ClassLink>();
  }

  Future<void> setArchive(String id, bool value) async {
    var box = await _box.box;
    box.get(id).isArchived = value;
    notifyListeners();
  }
}
