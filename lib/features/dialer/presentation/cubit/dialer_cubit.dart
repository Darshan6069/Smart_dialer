import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../native_bridge/native_bridge.dart';
import '../../../contacts/domain/entities/contact_entity.dart';
import '../../../contacts/domain/usecases/get_contacts.dart';
import 'dialer_state.dart';

class DialerCubit extends Cubit<DialerState> {
  final NativeBridge nativeBridge;
  final GetContactsUseCase getContactsUseCase;

  DialerCubit({
    required this.nativeBridge,
    required this.getContactsUseCase,
  }) : super(const DialerState.empty()) {
    checkSystemDialerStatus();
  }

  Future<void> checkSystemDialerStatus() async {
    final status = await nativeBridge.isSystemDialer();
    state.maybeWhen(
      empty: (isSys) => emit(DialerState.empty(isSystemDialer: status)),
      typing: (numberVal, search, isSys) => emit(DialerState.typing(number: numberVal, searchResults: search, isSystemDialer: status)),
      orElse: () => emit(DialerState.empty(isSystemDialer: status)),
    );
  }

  Future<void> requestSystemDialer() async {
    final status = await nativeBridge.setSystemDialer();
    state.maybeWhen(
      empty: (isSys) => emit(DialerState.empty(isSystemDialer: status)),
      typing: (numberVal, search, isSys) => emit(DialerState.typing(number: numberVal, searchResults: search, isSystemDialer: status)),
      orElse: () => emit(DialerState.empty(isSystemDialer: status)),
    );
  }

  void addDigit(String digit) {
    final currentNumber = state.maybeWhen(
      typing: (numberVal, _, __) => numberVal,
      orElse: () => '',
    );
    _updateInputAndSearch(currentNumber + digit);
  }

  void removeDigit() {
    final currentNumber = state.maybeWhen(
      typing: (numberVal, _, __) => numberVal,
      orElse: () => '',
    );
    if (currentNumber.isNotEmpty) {
      final newNumber = currentNumber.substring(0, currentNumber.length - 1);
      _updateInputAndSearch(newNumber);
    }
  }

  void clearDialer() {
    _updateInputAndSearch('');
  }

  Future<void> _updateInputAndSearch(String number) async {
    final isSys = state.maybeWhen(
      empty: (isSys) => isSys,
      typing: (numberVal, search, isSys) => isSys,
      orElse: () => false,
    );

    if (number.isEmpty) {
      emit(DialerState.empty(isSystemDialer: isSys));
      return;
    }

    // 1. Instantly emit the updated number to prevent dialpad typing latency
    final List<ContactEntity> currentResults = state.maybeWhen(
      typing: (_, search, __) => search,
      orElse: () => const <ContactEntity>[],
    );
    emit(DialerState.typing(number: number, searchResults: currentResults, isSystemDialer: isSys));

    // 2. Query matching contacts in the background
    try {
      final contacts = await getContactsUseCase(query: number);
      // Verify user has not typed further before updating matching results
      state.maybeWhen(
        typing: (currentNum, _, sys) {
          if (currentNum == number) {
            emit(DialerState.typing(number: number, searchResults: contacts, isSystemDialer: sys));
          }
        },
        orElse: () {},
      );
    } catch (_) {
      // Keep state intact
    }
  }

  Future<void> makeCall(String number) async {
    emit(const DialerState.calling());
    try {
      final success = await nativeBridge.makeCall(number);
      if (!success) {
        emit(const DialerState.error('Could not initiate system phone call.'));
        clearDialer();
      }
    } catch (e) {
      emit(DialerState.error('Error starting call: $e'));
      clearDialer();
    }
  }
}
