import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchCubit extends Cubit<bool> {
  SwitchCubit() : super(false);

  void updateValue(bool value) {
    emit(value);
  }
}
