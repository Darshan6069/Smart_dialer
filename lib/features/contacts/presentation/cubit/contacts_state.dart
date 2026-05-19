import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/contact_entity.dart';

part 'contacts_state.freezed.dart';

@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState.initial() = _Initial;
  const factory ContactsState.loading() = _Loading;
  const factory ContactsState.loaded(List<ContactEntity> contacts) = _Loaded;
  const factory ContactsState.error(String message) = _Error;
}
