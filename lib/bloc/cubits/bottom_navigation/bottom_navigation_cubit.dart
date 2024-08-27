import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../screens/bottom_navigation/home_page.dart';
import '../../states/bottom_navigation/bottom_navigation_state.dart';

class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(ManageProfileState());

  int pageIndex = 0;
  final pages = [
    const ManageProfile(),
    const HelmetConnected(),
    const Stats(),
    const SOS(),
  ];

  void setIndex(int index) {
    pageIndex = index;
    setScreen();
  }

  void setScreen() {
    if (pageIndex == 0) {
      emit(ManageProfileState());
    } else if (pageIndex == 1) {
      emit(HelmetConnectedState());
    } else if (pageIndex == 2) {
      emit(StatsState());
    } else if (pageIndex == 3) {
      emit(SOSState());
    }
  }
}
