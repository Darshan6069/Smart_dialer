import '../../domain/entities/contact_entity.dart';
import '../../domain/repository/contacts_repository.dart';
import '../datasource/contacts_local_datasource.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsLocalDataSource localDataSource;

  ContactsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ContactEntity>> getContacts({String? query}) async {
    return await localDataSource.getContacts(query: query);
  }

  @override
  Future<bool> requestPermission() async {
    return await localDataSource.requestPermission();
  }
}
