import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/assets.dart';

class BluetoothCubit extends Cubit<AppBluetoothState> {
  BluetoothCubit() : super(BluetoothStateInitial());

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
  bool connecting = true;
  BluetoothDevice? device;

  List<BluetoothDevice> scannedDevices = [];
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> adapterStateStateSubscription;
  List<BluetoothService> services = [];

  Future<void> checkPermissions() async {
    final bluetoothPermission = await Permission.bluetooth.isGranted;
    final locationPermission = await Permission.location.isGranted;
    // PermissionStatus status;

    if (!bluetoothPermission) {
      emit(BluetoothStateOff());
      await Permission.bluetooth.request();
    }
    if (!locationPermission) {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        await Permission.locationAlways.request();
      }
    }
  }

  // Future<void> checkStatus() async {
  //   var permission = Permission.bluetooth;
  //   if (await permission.isGranted) {
  //     emit(BluetoothStateOn());
  //     await getDevices();
  //     return;
  //   } else {
  // }

  Future<void> checkStatus() async {
    if (adapterState == BluetoothAdapterState.off) {
      emit(BluetoothStateOff());
      await FlutterBluePlus.turnOn();

      if (adapterState == BluetoothAdapterState.on) {
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

  void listenState() async {
    adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      adapterState = state;
      print('the state is $adapterState');
      if (adapterState == BluetoothAdapterState.off) {
        emit(BluetoothStateOff());
        await FlutterBluePlus.stopScan();
        // if (device?.isConnected ?? false) {
        disconnectReasonCode = 222;
        // await di.get<LocationService>().maintainLocationHistory(disconnectReasonCode);
        // await disconnectAlert(disconnectReasonCode);
        // await alarmSettings();
        // }
      } else if (adapterState == BluetoothAdapterState.on) {
        emit(BluetoothStateOn());
        getDevices();
      }
    }, onDone: () async {
      // FlutterBluePlus.stopScan();
      /// cancel scanning and streaming
    });
    // adapterStateStateSubscription.cancel();
  }

  Future<void> turnOn() async {
    try {
      FlutterBluePlus.turnOn();
      if (adapterState == BluetoothAdapterState.on) {
        emit(BluetoothStateOn());
        await getDevices();
      } else {
        emit(BluetoothStateOff());
        await FlutterBluePlus.stopScan();
        return;
      }
    } catch (e) {
      emit(BluetoothStateOff());
    }
  }

  Future<void> getDevices() async {
    try {
      if (isDiscovering) {
        await FlutterBluePlus.stopScan();
        isDiscovering = false;
        scannedDevices = [];
        emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
      } else {
        // print("adpter in scan is $adapterState");
        if (adapterState == BluetoothAdapterState.on) {
          isDiscovering = true;
          scannedDevices = [];

          emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));

          await FlutterBluePlus.startScan();
          FlutterBluePlus.scanResults.listen((event) async {
            for (ScanResult result in event) {
              if (!scannedDevices.contains(result.device) && (result.device.platformName.isNotEmpty)) {
                if (autoConnected) {
                  final device = await checkSavedDevice();
                  print('checked device in local storage is $device');
                  if (device != null) {
                    try {
                      if (result.device.platformName == device) {
                        print('condition is checked');
                        await connect(result.device);
                        return;
                      }
                    } catch (e) {
                      print("error $e");
                    }
                  }
                }
                scannedDevices.add(result.device);
                emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
              }
            }
          });
        } else {
          isDiscovering = false;
          Permission.bluetooth.request();
        }
      }
    } catch (e) {
      await FlutterBluePlus.stopScan();
      isDiscovering = false;
      scannedDevices = [];
      emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
      print('the error is $e');
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      final connection = await checkConnections();
      if (connection != null) {
        emit(BluetoothFailedState(message: 'Failed to connect'));
      }
      emit(BluetoothConnectingState());
      this.device = device;
      FlutterBluePlus.stopScan();
      print("the device is $device");
      await device.connect();

      if (this.device?.isConnected ?? false) {
        final convertedDevice = jsonEncode(this.device?.platformName);
        await StorageService().write(lastDeviceKey, convertedDevice);
        deviceName = device.platformName;
        await StorageService().write(connectTimeKey, DateTime.now().toIso8601String());

        await StorageService().write(lastDeviceKey, device.platformName);
        print('device saved');
        services = await device.discoverServices();

        var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
          if (state == BluetoothConnectionState.connected) {
            /// for battery
            final batterySub = services[2].characteristics[0].lastValueStream.listen((event) {
              try {
                double? value = event[0].toDouble();
                batteryPercentage = value ?? 0.0;
                print('the battery is $batteryPercentage');

                emit(BluetoothConnectedState(
                    deviceName: device.platformName,
                    batteryPercentage: batteryPercentage ?? 0.0,
                    isWore: isWore,
                    speed: 0));
              } catch (e) {
                print("error occured while getting value");
              }
            });

            device.cancelWhenDisconnected(batterySub);
            await services[2].characteristics[0].setNotifyValue(true);

            /// for head sensor
            final headSub = services[2].characteristics[1].lastValueStream.listen((event) {
              print("the head sensor status is $event");
              var value = event[0];
              isWore = value != null ? value : 0;
              emit(BluetoothConnectedState(
                  deviceName: device.platformName,
                  batteryPercentage: batteryPercentage ?? 0.0,
                  isWore: isWore,
                  speed: 0));
            });
            device.cancelWhenDisconnected(headSub);
            await services[2].characteristics[1].setNotifyValue(true);

            /// for cheek sensor
            // final cheekSub = services[2].characteristics[2].lastValueStream.listen((event) {
            //   print("the cheek sensor status is $event");
            // });
            //
            //
            // device.cancelWhenDisconnected(cheekSub);
            // await services[2].characteristics[2].setNotifyValue(true);
            // print("the state is ${state}");
          }

          if (state == BluetoothConnectionState.disconnected) {
            print("disconnected testing $state");
            disconnect(disconnectReasonCode);
            FlutterBluePlus.stopScan();
            getDevices();
          }
        });
        device.cancelWhenDisconnected(subscription, delayed: true, next: true);
        pop();
        emit(
          BluetoothConnectedState(
              speed: pressure ?? 0.0,
              deviceName: deviceName ?? '',
              batteryPercentage: batteryPercentage ?? 0.0,
              isWore: isWore),
        );
      } else {
        // FlutterBluePlus.startScan();
        await disconnect();
      }
    } catch (e) {
      pop();
      emit(
        BluetoothFailedState(message: 'Failed to connect'),
      );
      await disconnect();
      print(e);
    }
  }

  Future<String?> checkConnections() async {
    // final internet = await Connectivity().checkConnectivity();
    final locationService = await Geolocator.isLocationServiceEnabled();
    if (!locationService) {
      return 'Location';
    }
    // final device = await checkSavedDevice();
    // if (internet == ConnectivityResult.none && device == null) {
    //   return 'Internet';
    // }
    return null;
  }

  Future<String?> checkSavedDevice() async {
    final encodedDevice = await StorageService().read(lastDeviceKey);
    if (encodedDevice != null) {
      var device = encodedDevice;
      print('the last saved device is $device');
      return device;
    }
    return null;
  }

  Future<void> disconnect([int? reason]) async {
    log('$reason *******');

    // await bluetoothConnection?.finish();
    // await bluetoothConnection?.close();
    // await connection?.finish();
    // await inputStream?.cancel();

    device!.disconnect();
    disconnectReasonCode = reason ?? 0;
    emit(DisconnectedState(reason ?? 0));

    if (reason != null) {
      await di.get<LocationService>().maintainLocationHistory(disconnectReasonCode);
    }
    if (reason != null) await getDevices();
    await disconnectAlert(reason);
    await alarmSettings();
  }

  Future<void> disconnectAlert([int? reason]) async {
    if (reason != null) {
      await di.get<HelmetService>().disconnectingAlert(device?.platformName ?? 'N/A', disconnectReasonCode);
    }
  }

  Future<void> alarmSettings() async {
    await Future.delayed(
      const Duration(seconds: 15),
      () async {
        if ((device?.isConnected ?? false)) {
          return;
        }
        if (adapterState == BluetoothAdapterState.on) {
          print("adapter state in alarm is $adapterState");
          emit(AutoDisconnectedState(device?.platformName ?? ''));
          emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
        }
        isAlarmPlayed = true;
        await playAlarm();
        // }
      },
    );
  }

  Future<void> playAlarm() async {
    await audioPlayer.setAsset(AssetsPath.alarmSound);
    await audioPlayer.play();
  }

  @override
  Future<void> close() async {
    // await flutterBluetoothSerial.cancelDiscovery();
    // await bluetoothConnection?.finish();
    // await bluetoothConnection?.close();
    // await bluetoothStateStream?.cancel();
    // await bluetoothDiscoveryStream?.cancel();

    audioPlayer.dispose();

    // await connection?.finish();
    //
    // await inputStream?.cancel();

    return super.close();
  }
}
