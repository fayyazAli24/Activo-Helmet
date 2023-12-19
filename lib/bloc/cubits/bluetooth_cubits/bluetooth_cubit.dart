import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/assets.dart';

class BluetoothCubit extends Cubit<AppBluetoothState> {
  BluetoothCubit() : super(BluetoothStateInitial()) {
    checkPermissions();
    checkStatus();
    listenState();
  }

  BluetoothConnection? connection;

  List<BluetoothDiscoveryResult> scannedDevices = [];
  StreamSubscription<Uint8List>? inputStream;

  AudioPlayer audioPlayer = AudioPlayer();
  String? deviceName;
  String? connectedDeviceData;
  double? batteryPercentage;
  double? pressure;
  int isWore = 0;
  bool isDiscovering = false;
  int disconnectReasonCode = 0;
  bool autoConnected = false;
  bool isAlarmPlayed = false;
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
      } else {
        emit(BluetoothStateOff());
      }
    } else {
      emit(BluetoothStateOn());
      await getDevices();
    }
  }

  void listenState() {
    bluetoothStateStream = flutterBluetoothSerial.onStateChanged().listen(
          (event) async {
            if (event == BluetoothState.STATE_OFF) {
              emit(BluetoothStateOn());

              if (connection?.isConnected ?? false) {
                emit(BluetoothStateOff());
                disconnectReasonCode = 222;
                await di.get<LocationService>().maintainLocationHistory(disconnectReasonCode);
                await disconnectAlert(disconnectReasonCode);
                await alarmSettings();
              }
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
      } else {
        emit(BluetoothStateOff());
        return;
      }
    } catch (e) {
      emit(BluetoothStateOff());
    }
  }

  Future<void> getDevices() async {
    try {
      if (await flutterBluetoothSerial.isDiscovering ?? false) {
        await FlutterBluetoothSerial.instance.cancelDiscovery();
        isDiscovering = false;
        scannedDevices = [];
        emit(BluetoothScannedState(devices: scannedDevices));
      } else {
        final blueState = await flutterBluetoothSerial.state;
        if (blueState == BluetoothState.STATE_ON) {
          isDiscovering = true;
          scannedDevices = [];
          emit(BluetoothScannedState(devices: scannedDevices));

          bluetoothDiscoveryStream = flutterBluetoothSerial.startDiscovery().listen(
            (newDevice) async {
              final alreadyExists =
                  scannedDevices.indexWhere((element) => element.device.name == newDevice.device.name);
              if ((alreadyExists == -1) && (newDevice.device.name?.isNotEmpty ?? false)) {
                ///555 = user has voluntarily disconnected
                if (disconnectReasonCode != 555 && autoConnected) {
                  final device = await checkSavedDevice();
                  if (device != null) {
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
              isDiscovering = false;
              emit(BluetoothScannedState(devices: scannedDevices));
              await bluetoothDiscoveryStream?.cancel();
            },
            onError: (e) async {
              isDiscovering = false;

              emit(BluetoothScannedState(devices: scannedDevices));
              await bluetoothDiscoveryStream?.cancel();
            },
            cancelOnError: true,
          );
        } else {
          isDiscovering = false;
          await flutterBluetoothSerial.requestEnable();
        }
      }
    } catch (e) {
      log('$e');
      await FlutterBluetoothSerial.instance.cancelDiscovery();
      isDiscovering = false;
      scannedDevices = [];
      emit(BluetoothScannedState(devices: scannedDevices));
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      final connections = await checkConnections();
      if (connections != null) {
        emit(BluetoothFailedState(message: 'Please turn on the $connections'));
        return;
      }

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
            var newConnectedDeviceData = String.fromCharCodes(event);

            if (newConnectedDeviceData.contains(RegExp(r'[a-zA-Z0-9]'))) {
              if (newConnectedDeviceData != connectedDeviceData) {
                connectedDeviceData = newConnectedDeviceData;
                final splitData = connectedDeviceData?.split(',');
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
                disconnectReasonCode = 0;
                emit(
                  BluetoothConnectedState(
                    speed: pressure ?? 0.0,
                    deviceName: deviceName ?? '',
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
          onError: (e) {},
          cancelOnError: true,
        );

        ///close connecting dialog
        pop();
        emit(BluetoothConnectedState(
            speed: pressure ?? 0.0,
            deviceName: deviceName ?? '',
            batteryPercentage: batteryPercentage ?? 0.0,
            isWore: isWore));
      } else {
        await disconnect();
      }
    } catch (e) {
      pop();

      emit(
        BluetoothFailedState(message: 'Failed to connect'),
      );
      await disconnect();
    }
  }

  Future<String?> checkConnections() async {
    final internet = await Connectivity().checkConnectivity();
    final locationService = await Geolocator.isLocationServiceEnabled();
    if (!locationService) {
      return 'Location';
    }
    if (internet == ConnectivityResult.none) {
      return 'Internet';
    }
    return null;
  }

  Future<BluetoothDevice?> checkSavedDevice() async {
    final encodedDevice = await StorageService().read(lastDeviceKey);
    if (encodedDevice != null) {
      var device = BluetoothDevice.fromMap(json.decode(encodedDevice.toString()));
      return device;
    }
    return null;
  }

  Future<void> disconnect([int? reason]) async {
    log('$reason *******');

    await bluetoothConnection?.finish();
    await bluetoothConnection?.close();
    await connection?.finish();
    await inputStream?.cancel();
    disconnectReasonCode = reason ?? 0;
    await di.get<LocationService>().maintainLocationHistory(disconnectReasonCode);
    emit(DisconnectedState(reason ?? 0));
    await getDevices();
    await disconnectAlert(reason);

    await alarmSettings();
  }

  Future<void> disconnectAlert([int? reason]) async {
    if (reason != null) {
      await di.get<HelmetService>().disconnectingAlert(deviceName ?? 'N/A', disconnectReasonCode);
    }
  }

  Future<void> alarmSettings() async {
    await Future.delayed(
      const Duration(seconds: 15),
      () async {
        if ((connection?.isConnected ?? false) || isAlarmPlayed) return;
        if (await flutterBluetoothSerial.state == BluetoothState.STATE_ON) {
          emit(AutoDisconnectedState(deviceName ?? ''));
        }

        isAlarmPlayed = true;
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

    await inputStream?.cancel();

    return super.close();
  }
}
