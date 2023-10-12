import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

enum AppBluetoothState {
  connecting,
  scanning,
  scanned,
  on,
  off,
  disconnected,
  connected,
  error,
  newDeviceData,
  deviceDataUpdated
}

class BluetoothCubit extends Cubit<AppBluetoothState> {
  BluetoothCubit() : super(AppBluetoothState.off) {
    checkStatus();
    // getDevices();
  }

  List<BluetoothDiscoveryResult> devices = [];
  StreamSubscription<Uint8List>? inputStream;
  String? deviceName;
  String? deviceData;
  double? batteryPercentage;
  int isWore = 0;

  // Stream<List<ScanResult>>? scanResults;
  // StreamSubscription<List<ScanResult>>? subscription;
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothConnection? bluetoothConnection;
  checkStatus() async {
    final bluetoothState = await flutterBluetoothSerial.state;
    log("**bluetooth state :  $bluetoothState");
    if (bluetoothState == BluetoothState.STATE_OFF) {
      emit(AppBluetoothState.off);
      final isON = await flutterBluetoothSerial.requestEnable();
      if (isON ?? false) {
        emit(AppBluetoothState.on);
        getDevices();
      }
    } else {
      emit(AppBluetoothState.on);
      getDevices();
    }

    flutterBluetoothSerial.onStateChanged().listen((event) async {
      print("$event listening");
      if (event == BluetoothState.STATE_OFF) {
        emit(AppBluetoothState.off);
        final isON = await flutterBluetoothSerial.requestEnable();
        if (isON ?? false) {
          emit(AppBluetoothState.on);
        }
      } else if (bluetoothState == BluetoothState.STATE_ON) {
        emit(AppBluetoothState.on);
      }
    });
  }

  getDevices() async {
    final blueState = await flutterBluetoothSerial.state;

    if (blueState == BluetoothState.STATE_ON) {
      flutterBluetoothSerial.startDiscovery().listen((newDevice) {
        emit(AppBluetoothState.scanning);

        if (!devices.contains(newDevice) && (newDevice.device.name?.isNotEmpty ?? false)) {
          devices.add(newDevice);
          emit(AppBluetoothState.scanned);
        }
      });
    }
  }

  connect(BluetoothDevice device) async {
    try {
      emit(AppBluetoothState.connecting);
      deviceName = device.name;
      final connection = await BluetoothConnection.toAddress(device.address);
      if (connection.isConnected) {
        deviceName = device.name;

        inputStream = connection.input?.listen(
          (event) {
            String newData = String.fromCharCodes(event);

            emit(AppBluetoothState.newDeviceData);

            if (newData.contains(RegExp(r'[a-zA-Z0-9]'))) {
              // Process the data
              if (newData != deviceData) {
                deviceData = newData;

                final batteryValue = deviceData?.split(',')[1].toString();
                batteryPercentage = double.parse(batteryValue ?? "0");
                String deviceStatus = deviceData?.split(',')[0] ?? "0";
                isWore = int.parse(deviceStatus);

                emit(AppBluetoothState.deviceDataUpdated);
              }
            }
          },
          onDone: () {
            inputStream?.cancel();
          },
        );

        emit(AppBluetoothState.connected);
      } else {
        emit(AppBluetoothState.disconnected);
      }
    } catch (e) {
      pop();
      log("can't connect: $e");
      emit(AppBluetoothState.error);
    }
  }

  disconnect() async {
    await bluetoothConnection?.finish();
    await bluetoothConnection?.close();

    inputStream?.cancel();
    emit(AppBluetoothState.disconnected);
  }

  // checkBluetoothStatus() {
  //   FlutterBluePlus.adapterState.listen((event) async {
  //     if (event == BluetoothAdapterState.off) {
  //       emit(AppBluetoothState.off);
  //       if (Platform.isAndroid) {
  //         await FlutterBluePlus.turnOn();
  //         emit(AppBluetoothState.on);
  //         await startScan();
  //       } else {
  //         emit(AppBluetoothState.off);
  //       }
  //     } else {
  //       await startScan();
  //
  //       emit(AppBluetoothState.on);
  //     }
  //   });
  // }
  //
  // startScan() async {
  //   FlutterBluePlus.isScanning.listen((event) {
  //     if (event) {
  //       scanning = true;
  //     }
  //   });
  //
  //   if (scanning) {
  //     await FlutterBluePlus.stopScan();
  //   }
  //
  //   await FlutterBluePlus.startScan(
  //     timeout: const Duration(seconds: 5),
  //     oneByOne: false,
  //     androidUsesFineLocation: false,
  //     withServices: [],
  //     removeIfGone: const Duration(seconds: 3),
  //   );
  //   emit(AppBluetoothState.scanning);
  // }
  //
  // // getDevices() {
  // //   subscription = FlutterBluePlus.scanResults.listen((results) {
  // //     for (ScanResult result in results) {
  // //       if (!devices.contains(result) && result.device.platformName.isNotEmpty) {
  // //         devices.add(result);
  // //       } else {
  // //         devices.remove(result);
  // //       }
  // //     }
  // //
  // //     emit(AppBluetoothState.scanned);
  // //   });
  // // }
  //
  // turnOn() async {
  //   await FlutterBluePlus.turnOn();
  //   emit(AppBluetoothState.on);
  // }
  //
  // connect( device) async {
  //   try {
  //     emit(AppBluetoothState.connecting);
  //     await device.connect().then((value) {
  //       emit(AppBluetoothState.connected);
  //     });
  //   } catch (e) {
  //     log("$e");
  //     pop();
  //     emit(AppBluetoothState.error);
  //     emit(AppBluetoothState.scanned);
  //   }
  // }
  //
  // disconnect() async {
  //   final connectedDevices = await FlutterBluePlus.bondedDevices;
  //   await connectedDevices.first.disconnect();
  //   emit(AppBluetoothState.disconnected);
  // }

  snackBar(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        content: AppText(
          text: msg,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
