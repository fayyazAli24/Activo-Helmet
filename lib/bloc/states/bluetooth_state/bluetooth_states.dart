import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppBluetoothState {}

class BluetoothStateInitial extends AppBluetoothState {}

class BluetoothStateOn extends AppBluetoothState {}

class BluetoothStateOff extends AppBluetoothState {}

class BluetoothConnectingState extends AppBluetoothState {}

class BluetoothScannedState extends AppBluetoothState {
  // List<BluetoothDiscoveryResult> devices = [];
  List<BluetoothDevice> devices = [];
  bool isDiscovering = false;
  BluetoothScannedState({required this.devices, required this.isDiscovering});
}

class BluetoothConnectedState extends AppBluetoothState {
  double batteryPercentage = 0.0;
  String deviceName = '';
  int isWore = 0;
  double speed = 0.0;
  int cheek = 0;
  BluetoothConnectedState(
      {required this.deviceName,
      required this.batteryPercentage,
      required this.isWore,
      required this.speed,
      required this.cheek});
}

class DisconnectedState extends AppBluetoothState {
  int code;
  DisconnectedState(this.code);
}

class AutoDisconnectedState extends AppBluetoothState {
  String? name;

  AutoDisconnectedState(this.name);
}

class BluetoothFailedState extends AppBluetoothState {
  String? message;
  BluetoothFailedState({required this.message});
}
