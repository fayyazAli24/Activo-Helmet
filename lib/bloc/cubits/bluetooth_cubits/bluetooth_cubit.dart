import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/assets.dart';

class BluetoothCubit extends Cubit<AppBluetoothState> {
  BluetoothCubit() : super(AppBluetoothState()) {
    checkPermissions();
    checkStatus();
  }

  BluetoothConnection? connection;

  List<BluetoothDiscoveryResult> scannedDevices = [];
  StreamSubscription<Uint8List>? inputStream;
  StreamSubscription<Position>? locationStream;
  AudioPlayer audioPlayer = AudioPlayer();
  String? deviceName;
  String? deviceData;
  double? batteryPercentage;
  double? pressure;
  int isWore = 0;
  bool isStreamClosed = false;
  int disconnectReason = 0;
  bool autoConnected = false;
  StreamSubscription<BluetoothState>? bluetoothStateStream;
  StreamSubscription<BluetoothDiscoveryResult>? bluetoothDiscoveryStream;
  FlutterBluetoothSerial flutterBluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothConnection? bluetoothConnection;

  Future<void> checkPermissions() async {
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

  Future<void> checkStatus() async {
    final bluetoothState = await flutterBluetoothSerial.state;

    print('**bluetooth state :  $bluetoothState');
    if (bluetoothState == BluetoothState.STATE_OFF) {
      emit(BluetoothStateOff());
      final isON = await flutterBluetoothSerial.requestEnable();
      if (isON ?? false) {
        emit(BluetoothStateOn());
        await getDevices();
      }
    } else {
      emit(BluetoothStateOn());
      await getDevices();
    }

    bluetoothStateStream = flutterBluetoothSerial.onStateChanged().listen(
          (event) async {
            if (event == BluetoothState.STATE_OFF) {
              await checkStatus();
            } else if (event == BluetoothState.STATE_ON) {
              emit(BluetoothStateOn());
              await getDevices();
            }
          },
          onError: (e) async => await bluetoothStateStream?.cancel(),
          onDone: () async {
            await bluetoothStateStream?.cancel();
          },
        );
  }

  Future<void> turnOn() async {
    try {
      final isON = await flutterBluetoothSerial.requestEnable();
      if (isON ?? false) {
        emit(BluetoothStateOn());
        await getDevices();
      }
    } catch (e) {
      emit(BluetoothStateOff());
    }
  }

  Future<void> getDevices() async {
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    final blueState = await flutterBluetoothSerial.state;
    if (blueState == BluetoothState.STATE_ON) {
      scannedDevices = [];
      isStreamClosed = false;
      emit(BluetoothScannedState(devices: scannedDevices));
      bluetoothDiscoveryStream = flutterBluetoothSerial.startDiscovery().listen(
        (newDevice) async {
          final alreadyExists = scannedDevices.indexWhere((element) => element.device.name == newDevice.device.name);
          if ((alreadyExists == -1) && (newDevice.device.name?.isNotEmpty ?? false)) {
            if (disconnectReason != 555 && autoConnected) {
              final encodedDevice = await StorageService().read(lastDeviceKey);
              if (encodedDevice != null) {
                var device = BluetoothDevice.fromMap(json.decode(encodedDevice.toString()));
                if (newDevice.device == device) {
                  await connect(device);
                  return;
                }
              }
            }
            scannedDevices.add(newDevice);

            emit(BluetoothScannedState(devices: scannedDevices));
          }
        },
        onDone: () async {
          isStreamClosed = true;
          emit(BluetoothScannedState(devices: scannedDevices));
          await bluetoothDiscoveryStream?.cancel();
        },
        onError: (e) async {
          isStreamClosed = true;
          emit(BluetoothScannedState(devices: scannedDevices));
          await bluetoothDiscoveryStream?.cancel();
        },
        cancelOnError: true,
      );
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      emit(BluetoothConnectingState());
      deviceName = device.name;
      connection = await BluetoothConnection.toAddress(device.address);

      if (connection?.isConnected ?? false) {
        final convertedDevice = jsonEncode(device.toMap());
        await StorageService().write(lastDeviceKey, convertedDevice);
        deviceName = device.name;
        await StorageService().write(connectTimeKey, DateTime.now().toIso8601String());

        inputStream = connection?.input?.listen(
          (event) {
            var newData = String.fromCharCodes(event);

            if (newData.contains(RegExp(r'[a-zA-Z0-9]'))) {
              if (newData != deviceData) {
                deviceData = newData;
                final splitData = deviceData?.split(',');
                if (splitData?.isNotEmpty ?? false) {
                  var deviceStatus = splitData![0];

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

                disconnectReason = 0;
                emit(
                  BluetoothConnectedState(
                    speed: pressure ?? 0.0,
                    name: deviceName ?? '',
                    batteryPercentage: batteryPercentage ?? 0.0,
                    isWore: isWore,
                  ),
                );
              }
            }
          },
          onDone: () {
            disconnect(444);

            ///Helmet Disconnect
          },
          cancelOnError: true,
        );

        ///close connecting dialog
        pop();
        emit(BluetoothConnectedState(
            speed: pressure ?? 0.0,
            name: deviceName ?? '',
            batteryPercentage: batteryPercentage ?? 0.0,
            isWore: isWore));
      } else {
        await disconnect();
      }
    } catch (e) {
      pop();
      print("can't connect: $e");
      emit(
        BluetoothFailedState(message: 'Failed to connect'),
      );
      await disconnect();
    }
  }

  Future<void> disconnect([int? reason]) async {
    await bluetoothConnection?.finish();
    await bluetoothConnection?.close();
    await connection?.finish();
    await inputStream?.cancel();

    await locationStream?.cancel();
    disconnectReason = reason ?? 0;
    await StorageService().write(disconnectTimeKey, DateTime.now().toIso8601String());
    await getDevices();

    await di.get<HelmetService>().disconnectingAlert(deviceName ?? 'N/A', disconnectReason);

    emit(DisconnectedState());
    await alarmSettings();
  }

  Future<void> alarmSettings() async {
    await Future.delayed(
      const Duration(seconds: 15),
      () async {
        if ((connection?.isConnected ?? false)) return;
        emit(AutoDisconnectedState(deviceName ?? ''));
        await playAlarm();
      },
    );
  }

  Future<void> playAlarm() async {
    await audioPlayer.setAsset(AssetsPath.alarmSound);
    await audioPlayer.play();
  }

  @override
  Future<void> close() async {
    await flutterBluetoothSerial.cancelDiscovery();
    await bluetoothConnection?.finish();
    await bluetoothConnection?.close();
    await bluetoothStateStream?.cancel();
    await bluetoothDiscoveryStream?.cancel();
    audioPlayer.dispose();
    await connection?.finish();
    await locationStream?.cancel();
    await inputStream?.cancel();

    return super.close();
  }
}
