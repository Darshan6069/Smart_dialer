import '../entities/contact_entity.dart';

abstract class ContactsRepository {
  Future<List<ContactEntity>> getContacts({String? query});
  Future<bool> requestPermission();
}
