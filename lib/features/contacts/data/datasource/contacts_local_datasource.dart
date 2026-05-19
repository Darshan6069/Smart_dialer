import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/contact_model.dart'; // We'll create this model next

abstract class ContactsLocalDataSource {
  Future<List<ContactModel>> getContacts({String? query});
  Future<bool> requestPermission();
}

class ContactsLocalDataSourceImpl implements ContactsLocalDataSource {
  @override
  Future<bool> requestPermission() async {
    try {
      return await FlutterContacts.requestPermission(readonly: true);
    } catch (e) {
      throw PermissionException('Failed to request contact permissions.');
    }
  }

  @override
  Future<List<ContactModel>> getContacts({String? query}) async {
    try {
      final bool permissionGranted = await FlutterContacts.requestPermission(readonly: true);
      if (!permissionGranted) {
        throw PermissionException('Contact permission not granted.');
      }

      // Fetch contacts with high-res photos and phone/email properties
      final List<Contact> deviceContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      final List<ContactModel> mappedContacts = deviceContacts
          .map((c) => ContactModel.fromDeviceContact(c))
          .toList();

      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return mappedContacts.where((contact) {
          final matchesName = contact.displayName.toLowerCase().contains(lowerQuery);
          final matchesPhone = contact.phones.any((p) => p.contains(lowerQuery));
          return matchesName || matchesPhone;
        }).toList();
      }

      return mappedContacts;
    } catch (e) {
      if (e is PermissionException) rethrow;
      throw ServerException('Failed to load system contacts.');
    }
  }
}
