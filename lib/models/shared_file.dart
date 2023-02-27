import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:gakujo_task/api/parse.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

part 'shared_file.g.dart';

@HiveType(typeId: 7)
class SharedFile implements Comparable<SharedFile> {
  @HiveField(0)
  String subject;
  @HiveField(1)
  String title;
  @HiveField(2)
  String fileSize;
  @HiveField(3)
  List<String>? fileNames;
  @HiveField(4)
  String description;
  @HiveField(5)
  String publicPeriod;
  @HiveField(6)
  DateTime updateDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  @HiveField(7)
  bool isAcquired = false;
  @HiveField(8)
  bool isArchived = false;

  SharedFile(
    this.subject,
    this.title,
    this.fileSize,
    this.fileNames,
    this.description,
    this.publicPeriod,
    this.updateDateTime, {
    required this.isAcquired,
    required this.isArchived,
  });

  factory SharedFile.fromElement(Element element) {
    var subject =
        element.querySelectorAll('td')[1].text.trimWhiteSpace().trimSubject();
    var title =
        element.querySelectorAll('td')[2].querySelector('a')!.text.trim();
    var fileSize = element.querySelectorAll('td')[3].text.trim();
    var updateDateTime =
        element.querySelectorAll('td')[4].text.trim().parseDateTime();
    return SharedFile(
      subject,
      title,
      fileSize,
      null,
      '',
      '',
      updateDateTime,
      isAcquired: false,
      isArchived: false,
    );
  }

  void toRefresh(SharedFile sharedFile) {
    title = sharedFile.title;
    fileSize = sharedFile.fileSize;
    updateDateTime = sharedFile.updateDateTime;
  }

  void toDetail(Document document) {
    isAcquired = true;
    description =
        document.querySelectorAll('table.ttb_entry > tbody > tr > td')[2].text;
    publicPeriod = document
        .querySelectorAll('table.ttb_entry > tbody > tr > td')[3]
        .text
        .trimWhiteSpace();
  }

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      title.toLowerCase().contains(value.toLowerCase()) ||
      description.toLowerCase().contains(value.toLowerCase());

  @override
  String toString() => '$subject $title';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is SharedFile) {
      return subject == other.subject && title == other.title;
    }
    return false;
  }

  @override
  int get hashCode => subject.hashCode ^ title.hashCode;

  @override
  int compareTo(SharedFile other) {
    var compare1 = updateDateTime.compareTo(other.updateDateTime);
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

class SharedFileBox {
  Future<Box> box = Hive.openBox<SharedFile>('shared_file');

  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<SharedFile>('shared_file');
    }
  }
}

class SharedFileRepository extends ChangeNotifier {
  late SharedFileBox _sharedFileBox;

  SharedFileRepository(SharedFileBox sharedFileBox) {
    _sharedFileBox = sharedFileBox;
  }

  Future<void> add(SharedFile sharedFile, {bool overwrite = false}) async {
    var box = await _sharedFileBox.box;
    if (!overwrite && box.containsKey(sharedFile.hashCode)) {
      SharedFile oldSharedFile = box.get(sharedFile.hashCode)!;
      oldSharedFile.toRefresh(sharedFile);
      await box.put(sharedFile.hashCode, oldSharedFile);
    }
    await box.put(sharedFile.hashCode, sharedFile);
    notifyListeners();
  }

  Future<void> addAll(List<SharedFile> sharedFiles,
      {bool overwrite = false}) async {
    for (var sharedFile in sharedFiles) {
      await add(sharedFile, overwrite: overwrite);
    }
    notifyListeners();
  }

  Future<void> delete(SharedFile sharedFile) async {
    var box = await _sharedFileBox.box;
    await box.delete(sharedFile.hashCode);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    var box = await _sharedFileBox.box;
    await box.deleteFromDisk();
    await _sharedFileBox.open();
    notifyListeners();
  }

  Future<SharedFile?> get(int key) async {
    var box = await _sharedFileBox.box;
    return box.get(key);
  }

  Future<List<SharedFile>> getAll() async {
    var box = await _sharedFileBox.box;
    return box.values.toList().cast<SharedFile>();
  }

  Future<void> setArchive(String id, bool value) async {
    var box = await _sharedFileBox.box;
    box.get(id).isArchived = value;
    notifyListeners();
  }
}
