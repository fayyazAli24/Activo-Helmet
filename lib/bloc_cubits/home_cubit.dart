import 'package:flutter_bloc/flutter_bloc.dart';

enum HomeState {
  initial,
  loaded,
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial);
}
