import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  final String id;
  final String displayName;
  final List<String> phones;
  final List<String> emails;
  final Uint8List? photoBytes;

  const ContactEntity({
    required this.id,
    required this.displayName,
    required this.phones,
    required this.emails,
    this.photoBytes,
  });

  @override
  List<Object?> get props => [id, displayName, phones, emails, photoBytes];
}
