import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/recent_call.dart';

part 'recents_state.freezed.dart';

@freezed
class RecentsState with _$RecentsState {
  const factory RecentsState.initial() = _Initial;
  const factory RecentsState.loading() = _Loading;
  const factory RecentsState.loaded(List<RecentCall> recentCalls) = _Loaded;
  const factory RecentsState.error(String message) = _Error;
}
