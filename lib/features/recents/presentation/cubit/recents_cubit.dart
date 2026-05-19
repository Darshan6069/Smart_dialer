import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recent_call.dart';
import '../../domain/usecases/get_recent_calls.dart';
import '../../domain/usecases/save_recent_call.dart';
import '../../domain/usecases/clear_recent_calls.dart';
import 'recents_state.dart';

class RecentsCubit extends Cubit<RecentsState> {
  final GetRecentCallsUseCase getRecentCallsUseCase;
  final SaveRecentCallUseCase saveRecentCallUseCase;
  final ClearRecentCallsUseCase clearRecentCallsUseCase;

  RecentsCubit({
    required this.getRecentCallsUseCase,
    required this.saveRecentCallUseCase,
    required this.clearRecentCallsUseCase,
  }) : super(const RecentsState.initial());

  Future<void> loadRecentCalls() async {
    emit(const RecentsState.loading());
    try {
      final calls = await getRecentCallsUseCase();
      emit(RecentsState.loaded(calls));
    } catch (e) {
      emit(RecentsState.error(e.toString()));
    }
  }

  Future<void> addCallToHistory(RecentCall call) async {
    try {
      await saveRecentCallUseCase(call);
      await loadRecentCalls();
    } catch (e) {
      emit(RecentsState.error(e.toString()));
    }
  }

  Future<void> clearHistory() async {
    emit(const RecentsState.loading());
    try {
      await clearRecentCallsUseCase();
      emit(const RecentsState.loaded([]));
    } catch (e) {
      emit(RecentsState.error(e.toString()));
    }
  }
}
