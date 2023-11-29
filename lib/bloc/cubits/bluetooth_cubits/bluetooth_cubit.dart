import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_states.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';

class BluetoothCubit extends Cubit<AppBluetoothState> {
  BluetoothCubit() : super(AppBluetoothState()) {
    checkPermissions();
    checkStatus();
    // getDevices();
  }

  BluetoothConnection? connection;
  List<BluetoothDiscoveryResult> devices = [];
  StreamSubscription<Uint8List>? inputStream;
  StreamSubscription<Position>? locationStream;
  String? deviceName;
  String? deviceData;
  double? batteryPercentage;
  double? pressure;
  int isWore = 0;
  bool autoConnected = false;
  StreamSubscription<BluetoothState>? bluetoothStateStream;
  StreamSubscription<BluetoothDiscoveryResult>? bluetoothDiscoveryStream;
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothConnection? bluetoothConnection;

  checkPermissions() async {
    final bluetoothPermission = await Permission.bluetooth.isGranted;
    final locationPermission = await Permission.location.isGranted;

    if (!bluetoothPermission) {
      emit(BluetoothStateOff());
      await Permission.bluetooth.request();
    }
    if (!locationPermission) {
      await Permission.location.request();
    }
  }

  checkStatus() async {
    final bluetoothState = await flutterBluetoothSerial.state;

    log("**bluetooth state :  $bluetoothState");
    if (bluetoothState == BluetoothState.STATE_OFF) {
      emit(BluetoothStateOff());
      final isON = await flutterBluetoothSerial.requestEnable();
      if (isON ?? false) {
        emit(BluetoothStateOn());
        getDevices();
      }
    } else {
      emit(BluetoothStateOn());

      getDevices();
    }

    bluetoothStateStream = flutterBluetoothSerial.onStateChanged().listen(
          (event) async {
            if (event == BluetoothState.STATE_OFF) {
              checkStatus();
            } else if (event == BluetoothState.STATE_ON) {
              emit(BluetoothStateOn());
              getDevices();
            }
          },
          onError: (e) async => await bluetoothStateStream?.cancel(),
          onDone: () async {
            await bluetoothStateStream?.cancel();
          },
        );
  }

  turnOn() async {
    try {
      final isON = await flutterBluetoothSerial.requestEnable();
      if (isON ?? false) {
        emit(BluetoothStateOn());
        getDevices();
      }
    } catch (e) {}
  }

  getDevices() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    final blueState = await flutterBluetoothSerial.state;

    if (blueState == BluetoothState.STATE_ON) {
      devices = [];

      bluetoothDiscoveryStream = flutterBluetoothSerial.startDiscovery().listen(
        (newDevice) {
          if (!devices.contains(newDevice) && (newDevice.device.name?.isNotEmpty ?? false)) {
            devices.add(newDevice);
            emit(BluetoothScannedState(devices: devices));
          }
        },
        onError: (e) async => await bluetoothDiscoveryStream?.cancel(),
      );
    }
  }

  autoConnect(bool value) async {
    final convertedDevice = await StorageService().read(lastDeviceKey);

    print("$convertedDevice");

    if (convertedDevice != null) {
      BluetoothDevice device = BluetoothDevice.fromMap(json.decode(convertedDevice.toString()));

      await connect(device);
      autoConnected = true;
    } else {
      autoConnected = false;

      emit(
        BluetoothFailedState(message: "Something went wrong / No Device Found"),
      );
    }
  }

  connect(BluetoothDevice device) async {
    try {
      emit(BluetoothConnectingState());
      deviceName = device.name;
      connection = await BluetoothConnection.toAddress(device.address);

      if (connection?.isConnected ?? false) {
        final convertedDevice = jsonEncode(device.toMap());
        await StorageService().write(lastDeviceKey, convertedDevice);
        deviceName = device.name;
        inputStream = connection?.input?.listen(
          (event) {
            String newData = String.fromCharCodes(event);

            if (newData.contains(RegExp(r'[a-zA-Z0-9]'))) {
              if (newData != deviceData) {
                deviceData = newData;
                final splitData = deviceData?.split(',');
                if (splitData?.isNotEmpty ?? false) {
                  String deviceStatus = splitData![0];

                  final parsedStatus = int.parse(deviceStatus);

                  ///condition inverted
                  isWore = parsedStatus == 0 ? 1 : 0;
                  if (splitData.length > 1) {
                    final batteryValue = splitData[1].toString();
                    batteryPercentage = double.tryParse(batteryValue);

                    ///pressure
                    pressure = double.tryParse(splitData[2]);
                  }
                }
                emit(
                  BluetoothConnectedState(
                    speed: pressure ?? 0.0,
                    name: deviceName ?? "",
                    batteryPercentage: batteryPercentage ?? 0.0,
                    isWore: isWore,
                  ),
                );
              }
            }
          },
          onDone: () {
            disconnect();
          },
          cancelOnError: true,
        );

        ///close connecting dialog
        pop();
        emit(BluetoothConnectedState(
            speed: pressure ?? 0.0,
            name: deviceName ?? "",
            batteryPercentage: batteryPercentage ?? 0.0,
            isWore: isWore));
      } else {
        disconnect();
      }
    } catch (e) {
      pop();
      log("can't connect: $e");
      emit(BluetoothFailedState(message: "Failed to connect"));
      disconnect();
    }
  }

  disconnect() async {
    await bluetoothConnection?.finish();
    await bluetoothConnection?.close();
    await connection?.finish();
    await inputStream?.cancel();
    await locationStream?.cancel();
    autoConnected = false;
    getDevices();
    emit(DisconnectedState());
  }

  @override
  Future<void> close() async {
    await flutterBluetoothSerial.cancelDiscovery();
    await bluetoothConnection?.finish();
    await bluetoothConnection?.close();
    await bluetoothStateStream?.cancel();

    await bluetoothDiscoveryStream?.cancel();
    await connection?.finish();
    await locationStream?.cancel();
    await inputStream?.cancel();
    return super.close();
  }
}
