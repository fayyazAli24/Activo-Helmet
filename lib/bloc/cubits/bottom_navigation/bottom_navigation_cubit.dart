import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../screens/bottom_navigation/screens/helmet_connect.dart';
import '../../../screens/bottom_navigation/screens/manage_profile.dart';
import '../../../screens/bottom_navigation/screens/sos.dart';
import '../../../screens/bottom_navigation/screens/stats.dart';
import '../../states/bottom_navigation/bottom_navigation_state.dart';

class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(HelmetConnectedState());

  int pageIndex = 0;
  final pages = [
    HelmetConnected(),
    Stats(),
    SOS(),
    const ManageProfile(),
  ];

  void setIndex(int index) {
    pageIndex = index;
    setScreen();
  }

  void setScreen() {
    if (pageIndex == 0) {
      emit(HelmetConnectedState());
    } else if (pageIndex == 1) {
      emit(StatsState());
    } else if (pageIndex == 2) {
      emit(SOSState());
      // emit(ManageProfileState());
    } else if (pageIndex == 3) {
      emit(ManageProfileState());
    }
  }
}
