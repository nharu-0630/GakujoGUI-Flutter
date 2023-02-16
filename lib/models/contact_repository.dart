import 'package:gakujo_task/models/contact.dart';

class ContactRepository {
  late ContactBox _contactBox;

  ContactRepository(ContactBox contactBox) {
    _contactBox = contactBox;
  }

  Future<void> add(Contact contact, {bool overwrite = false}) async {
    final box = await _contactBox.box;
    if (!overwrite && box.containsKey(contact.hashCode)) return;
    await box.put(contact.hashCode, contact);
  }

  Future<void> addAll(List<Contact> contacts) async {
    final box = await _contactBox.box;
    for (final contact in contacts) {
      await box.put(contact.hashCode, contact);
    }
  }

  Future<void> delete(Contact contact) async {
    final box = await _contactBox.box;
    await box.delete(contact.hashCode);
  }

  Future<void> deleteAll() async {
    final box = await _contactBox.box;
    await box.deleteFromDisk();
    await _contactBox.open();
  }

  Future<List<Contact>> getAll() async {
    final box = await _contactBox.box;
    return box.values.toList().cast<Contact>();
  }

  Future<List<Contact>> getSubjects(String subject) async {
    final box = await _contactBox.box;
    return box.values
        .where((contact) => contact.subjects == subject)
        .toList()
        .cast<Contact>();
  }
}
