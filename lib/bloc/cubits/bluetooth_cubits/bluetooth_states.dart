import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AppBluetoothState {}

class BluetoothStateOn extends AppBluetoothState {}

class BluetoothStateOff extends AppBluetoothState {}

class BluetoothConnectingState extends AppBluetoothState {}

class BluetoothScannedState extends AppBluetoothState {
  List<BluetoothDiscoveryResult> devices = [];

  BluetoothScannedState({required this.devices});
}

class BluetoothConnectedState extends AppBluetoothState {
  double batteryPercentage = 0.0;

  int isWore = 0;

  BluetoothConnectedState({required this.batteryPercentage, required this.isWore});
}

class DisconnectedState extends AppBluetoothState {}

class BluetoothFailedState extends AppBluetoothState {
  String? message;
  BluetoothFailedState({required this.message});
}
