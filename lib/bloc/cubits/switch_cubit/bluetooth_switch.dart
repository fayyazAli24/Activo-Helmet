import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothSwitch extends Cubit<bool> {
  BluetoothSwitch() : super(false) {
    initialValue();
  }

  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> adapterStateStateSubscription;
  bool savedValue = false;

  Future<bool> initialValue() async {
    adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      adapterState = state;

      if (state == BluetoothAdapterState.off) {
        savedValue = false;
        emit(false);
      } else if (state == BluetoothAdapterState.on) {
        savedValue = true;
        emit(true);
      }
    });

    return savedValue;
  }

  Future<void> updateValue(bool value) async {
    emit(value);
  }
}
