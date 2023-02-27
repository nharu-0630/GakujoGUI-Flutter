import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_task/api/parse.dart';
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

  ClassLink(
    this.subject,
    this.title,
    this.id,
    this.comment,
    this.link, {
    required this.isAcquired,
    required this.isArchived,
  });

  factory ClassLink.fromElement(Element element) {
    var subject =
        element.querySelectorAll('td')[1].text.trimWhiteSpace().trimSubject();
    var title =
        element.querySelectorAll('td')[2].querySelector('a')!.text.trim();
    var comment = element.querySelectorAll('td')[3].text.trim();
    var id = element
        .querySelectorAll('td')[2]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(0)
        .replaceAll('javascript:moveToDetail', '');
    return ClassLink(
      subject,
      title,
      id,
      comment,
      '',
      isAcquired: false,
      isArchived: false,
    );
  }

  void toDetail(Document document) {
    isAcquired = true;
    print(document
        .querySelectorAll('table.ttb_entry > tbody > tr > td')
        .map(
          (e) => e.innerHtml,
        )
        .join(','));
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
  String toString() => '$subject $title';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
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
    if (compare1 != 0) {
      return compare1;
    }
    var compare2 = title.compareTo(other.title);
    if (compare2 != 0) {
      return compare2;
    }
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
  late ClassLinkBox _classLinkBox;

  ClassLinkRepository(ClassLinkBox classLinkBox) {
    _classLinkBox = classLinkBox;
  }

  Future<void> add(ClassLink classLink, {bool overwrite = false}) async {
    var box = await _classLinkBox.box;
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
    var box = await _classLinkBox.box;
    await box.delete(classLink.id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _classLinkBox.box;
    await box.deleteFromDisk();
    await _classLinkBox.open();
    notifyListeners();
  }

  Future<ClassLink?> get(int key) async {
    var box = await _classLinkBox.box;
    return box.get(key);
  }

  Future<List<ClassLink>> getAll() async {
    var box = await _classLinkBox.box;
    return box.values.toList().cast<ClassLink>();
  }

  Future<void> setArchive(String id, bool value) async {
    var box = await _classLinkBox.box;
    box.get(id).isArchived = value;
    notifyListeners();
  }
}
