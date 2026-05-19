import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState.initial());

  void changeTab(int index) {
    emit(HomeState.initial(currentTabIndex: index));
  }
}
