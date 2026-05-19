import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_contacts.dart';
import 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final GetContactsUseCase getContactsUseCase;

  ContactsCubit({required this.getContactsUseCase}) : super(const ContactsState.initial());

  Future<void> loadContacts({String? query}) async {
    emit(const ContactsState.loading());
    try {
      final contacts = await getContactsUseCase(query: query);
      emit(ContactsState.loaded(contacts));
    } catch (e) {
      emit(ContactsState.error(e.toString()));
    }
  }

  Future<void> searchContacts(String query) async {
    // Immediate state search filter
    try {
      final contacts = await getContactsUseCase(query: query);
      emit(ContactsState.loaded(contacts));
    } catch (e) {
      emit(ContactsState.error(e.toString()));
    }
  }
}
