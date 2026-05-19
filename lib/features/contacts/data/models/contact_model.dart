import 'package:flutter_contacts/flutter_contacts.dart';
import '../../domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.displayName,
    required super.phones,
    required super.emails,
    super.photoBytes,
  });

  factory ContactModel.fromDeviceContact(Contact contact) {
    return ContactModel(
      id: contact.id,
      displayName: contact.displayName,
      phones: contact.phones.map((p) => p.number).toList(),
      emails: contact.emails.map((e) => e.address).toList(),
      photoBytes: contact.photo,
    );
  }
}
