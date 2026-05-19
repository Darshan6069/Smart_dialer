import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial({
    @Default(0) int currentTabIndex,
  }) = _Initial;
}
