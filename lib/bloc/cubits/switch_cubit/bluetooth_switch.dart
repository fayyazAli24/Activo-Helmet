import 'package:flutter_bloc/flutter_bloc.dart';

class BluetoothSwitch extends Cubit<bool> {
  BluetoothSwitch() : super(false) {
    initialValue();
  }

  Future<bool> initialValue() async {
    bool savedValue = false;
    return savedValue;
  }

  Future<void> updateValue(bool value) async {
    emit(value);
  }
}
