import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/services/storage_services.dart';
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

  BluetoothConnection? connection;
  List<BluetoothDiscoveryResult> devices = [];
  StreamSubscription<Uint8List>? inputStream;
  String? deviceName;
  String? deviceData;
  double? batteryPercentage;
  int isWore = 0;
  bool autoConnected = false;
  StreamSubscription<BluetoothState>? bluetoothStateStream;
  StreamSubscription<BluetoothDiscoveryResult>? bluetoothDiscoveryStream;
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

    bluetoothStateStream = flutterBluetoothSerial.onStateChanged().listen(
      (event) async {
        if (event == BluetoothState.STATE_OFF) {
          emit(AppBluetoothState.off);
          final isON = await flutterBluetoothSerial.requestEnable();
          if (isON ?? false) {
            emit(AppBluetoothState.on);
            getDevices();
          }
        } else if (bluetoothState == BluetoothState.STATE_ON) {
          emit(AppBluetoothState.on);
          getDevices();
        }
      },
      onDone: () {
        disconnect();
      },
      cancelOnError: true,
    );
  }

  getDevices() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    final blueState = await flutterBluetoothSerial.state;

    if (blueState == BluetoothState.STATE_ON) {
      devices = [];

      bluetoothDiscoveryStream = flutterBluetoothSerial.startDiscovery().listen(
        (newDevice) {
          emit(AppBluetoothState.scanning);

          if (!devices.contains(newDevice) && (newDevice.device.name?.isNotEmpty ?? false)) {
            devices.add(newDevice);
            emit(AppBluetoothState.scanned);
          }
        },
        cancelOnError: true,
      );
    }
  }

  autoConnect(bool value) async {
    BluetoothDevice? device = await StorageService().read(lastDeviceKey);
    print("$value");

    if (device != null) {
      await connect(device);
      autoConnected = true;
    } else {
      autoConnected = false;
      emit(AppBluetoothState.disconnected);
    }
  }

  connect(BluetoothDevice device) async {
    try {
      emit(AppBluetoothState.connecting);
      deviceName = device.name;

      connection = await BluetoothConnection.toAddress(device.address);

      if (connection?.isConnected ?? false) {
        await StorageService().write(lastDeviceKey, device);
        deviceName = device.name;
        inputStream = connection?.input?.listen(
          (event) {
            String newData = String.fromCharCodes(event);

            emit(AppBluetoothState.newDeviceData);

            if (newData.contains(RegExp(r'[a-zA-Z0-9]'))) {
              if (newData != deviceData) {
                deviceData = newData;
                log("$deviceData");

                final batteryValue = deviceData?.split(',')[1].toString();
                batteryPercentage = double.parse(batteryValue ?? "0");
                String deviceStatus = deviceData?.split(',')[0] ?? "0";
                isWore = int.parse(deviceStatus);

                emit(AppBluetoothState.deviceDataUpdated);
              }
            }
          },
          onDone: () {
            disconnect();
          },
          cancelOnError: true,
        );
        pop();

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
    await flutterBluetoothSerial.cancelDiscovery();
    await bluetoothConnection?.finish();
    await bluetoothConnection?.close();
    await bluetoothDiscoveryStream?.cancel();

    await connection?.finish();
    await inputStream?.cancel();

    autoConnected = false;
    emit(AppBluetoothState.disconnected);

    getDevices();
  }
}
