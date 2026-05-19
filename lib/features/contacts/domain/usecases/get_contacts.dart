import '../entities/contact_entity.dart';
import '../repository/contacts_repository.dart';

class GetContactsUseCase {
  final ContactsRepository repository;

  GetContactsUseCase(this.repository);

  Future<List<ContactEntity>> call({String? query}) async {
    return await repository.getContacts(query: query);
  }
}
