import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../contacts/domain/entities/contact_entity.dart';

part 'dialer_state.freezed.dart';

@freezed
class DialerState with _$DialerState {
  const factory DialerState.empty({
    @Default(false) bool isSystemDialer,
  }) = _Empty;

  const factory DialerState.typing({
    required String number,
    @Default([]) List<ContactEntity> searchResults,
    @Default(false) bool isSystemDialer,
  }) = _Typing;

  const factory DialerState.calling() = _Calling;

  const factory DialerState.error(String message) = _Error;
}
