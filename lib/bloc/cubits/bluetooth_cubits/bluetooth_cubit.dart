import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  bool loading = false;
  String? connectedDeviceData;
  double? batteryPercentage;
  double? pressure;
  int isWore = 0;
  bool isDiscovering = false;
  int disconnectReasonCode = 0;
  bool autoConnected = false;
  bool isAlarmPlayed = false;
  bool connecting = true;
  BluetoothDevice? connectedDevice;
  StreamSubscription<List<ScanResult>>? resultsStream;
  var timer;
  int check = 0;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  List<BluetoothDevice> scannedDevices = [];
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> adapterStateStateSubscription;
  List<BluetoothService> services = [];

  Future<void> checkPermissions() async {
    final bluetoothPermission = await Permission.bluetooth.isGranted;
    final locationPermission = await Permission.location.isGranted;
    bool check = false;
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

  void listenState() async {
    adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) async {
      adapterState = state;

      if (state == BluetoothAdapterState.off) {
        if (connectedDevice != null) {
          disconnectReasonCode = 222;
          disconnectDevice(disconnectReasonCode);
          print('ruk rha scan');
          FlutterBluePlus.stopScan();
        }

        emit(BluetoothStateOff());
      } else if (state == BluetoothAdapterState.on) {
        emit(BluetoothStateOn());
        print("from listen state");
        await getDevices();
      }
    }, onDone: () async {
      await FlutterBluePlus.stopScan();

      /// cancel scanning and streaming
    });

    // adapterStateStateSubscription.cancel();
  }

  Future<void> test() async {
    await Future.delayed(Duration(seconds: 5));
    print('&&&& ${FlutterBluePlus.adapterStateNow}');
    if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) {
      if (deviceName != null) {
        disconnectReasonCode = 444;
        await disconnectDevice(disconnectReasonCode);
        print('pehley yeh chala');
      }
    }
  }

  Future<void> turnOn() async {
    try {
      print('turn on');
      await FlutterBluePlus.turnOn();

      return;
      // }
    } catch (e) {
      emit(BluetoothStateOff());
    }
  }

  Future<void> getDevices() async {
    try {
      if (adapterState == BluetoothAdapterState.on) {
        isDiscovering = true;
        scannedDevices = [];
        emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
        await FlutterBluePlus.startScan();
        resultsStream = FlutterBluePlus.scanResults.listen(
          (event) async {
            for (ScanResult result in event) {
              if (!scannedDevices.contains(result.device) && (result.device.platformName.isNotEmpty)) {
                scannedDevices.add(result.device);
                if (autoConnected) {
                  for (int i = 0; i < scannedDevices.length; i++) {
                    final device = await checkSavedDevice();
                    print('checked device in local storage is $device');
                    if (device != null) {
                      try {
                        if (scannedDevices[i].platformName == device) {
                          print('condition is checked');
                          await connect(result.device);
                          await FlutterBluePlus.stopScan();
                          return;
                        }
                      } catch (e) {
                        print('error $e');
                      }
                    }
                  }
                }
                emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
              }
            }
          },
          onDone: () {
            resultsStream?.cancel();
          },
        );
      } else {
        isDiscovering = false;
        Permission.bluetooth.request();
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
        print('scanning');
        await getDevices();
        return;
      }
      emit(BluetoothConnectingState());
      connectedDevice = device;
      await FlutterBluePlus.stopScan();

      print('the device is $connectedDevice');
      await device.connect();

      if (connectedDevice?.isConnected ?? false) {
        final convertedDevice = connectedDevice?.platformName;
        await StorageService().write(lastDeviceKey, convertedDevice ?? '');
        deviceName = device.platformName;
        await StorageService().write(connectTimeKey, DateTime.now().toIso8601String());

        print('device saved');
        services = await device.discoverServices();

        try {
          _connectionStateSubscription = device.connectionState.listen(
            (BluetoothConnectionState state) async {
              if (state == BluetoothConnectionState.connected) {
                final batterySub = services[2].characteristics[0].lastValueStream.listen(
                  (event) async {
                    try {
                      if (event.isNotEmpty) {
                        print('check battery if');
                        double value = event[0].toDouble();
                        batteryPercentage = value;
                        print('the battery is $batteryPercentage');

                        var temp = await device.discoverServices();
                        print("the length is ${temp.length}");
                      } else {
                        print('check battery else');
                        batteryPercentage = 0.0;
                      }

                      emit(BluetoothConnectedState(
                          deviceName: device.platformName,
                          batteryPercentage: batteryPercentage ?? 0.0,
                          isWore: isWore,
                          speed: 0));
                    } catch (e) {
                      print('error occured while getting value');
                    }
                  },
                );
                device.cancelWhenDisconnected(batterySub);
                await services[2].characteristics[0].setNotifyValue(true);

                /// for head sensor
                final headSub = services[2].characteristics[1].lastValueStream.listen((event) {
                  print('the head sensor status is $event');
                  if (event.isNotEmpty) {
                    print('check head if');
                    isWore = event[0];
                  } else {
                    print('check head else');
                    isWore = 0;
                  }

                  emit(BluetoothConnectedState(
                      deviceName: device.platformName,
                      batteryPercentage: batteryPercentage ?? 0.0,
                      isWore: isWore,
                      speed: 0));
                });
                device.cancelWhenDisconnected(headSub);
                await services[2].characteristics[1].setNotifyValue(true);
              } else if (state == BluetoothConnectionState.disconnected) {
                // await disconnectDevice();
                await test();
              }

              /// for cheek sensor
              // final cheekSub = services[2].characteristics[2].lastValueStream.listen((event) {
              //   print("the cheek sensor status is $event");
              // });
              //
              //
              // device.cancelWhenDisconnected(cheekSub);
              // await services[2].characteristics[2].setNotifyValue(true);
              // print("the state is ${state}");
              // }

              //  },onDone: (){
              //   print('called from on done');
              //   disconnect(444);
            },
            onDone: () async {
              // disconnectReasonCode = 444;
              // await disconnectDevice(disconnectReasonCode);
            },
          );
          device.cancelWhenDisconnected(_connectionStateSubscription!, delayed: true, next: true);
        } catch (e) {
          // device.cancelWhenDisconnected(subscription, delayed: true, next: true);
          // log("coneccted $e");
        }

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
        pop();

        print('called from else');
        await disconnectDevice();
      }
    } catch (e) {
      pop();
      emit(
        BluetoothFailedState(message: 'Failed to connect'),
      );
      print('called from catch');
      disconnectDevice();
      print("called");
      await getDevices();
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

  Future<void> disconnectDevice([int? reason]) async {
    log('$reason *******');

    connectedDevice?.disconnect();
    _connectionStateSubscription?.cancel();
    // device?.cancelWhenDisconnected(subscription, delayed: true, next: true);
    emit(DisconnectedState(reason ?? 0));

    var device = await checkSavedDevice();
    print('the reason is $reason');
    if (reason != null && device != null) {
      print('---------maintain location history');
      await di.get<LocationService>().maintainLocationHistory(disconnectReasonCode);
    }

    // print('calling again and again');
    if (reason != null) {
      print('again connecting from dc method');
      // await getDevices();
      isAlarmPlayed = false;
      disconnectAlert(reason);

      alarmSettings();

      resultsStream?.cancel();

      connectedDevice = null;
      print('the connected device is $connectedDevice');

      // disconnectReasonCode = 0;
    }
  }

  Future<void> disconnectAlert([int? reason]) async {
    if (reason != null) {
      print("---in disconnected alert");
      var test = deviceName ?? 'N/A';

      if (test == 'N/A') {
        var temp = await checkSavedDevice();
        if (temp != null) {
          print("ifheueheueheu");
          await di.get<HelmetService>().disconnectingAlert(temp, disconnectReasonCode);
          return;
        } else {
          print("heueheueheu");
          return;
        }
      } else {
        await di.get<HelmetService>().disconnectingAlert(test, disconnectReasonCode);
      }
    }
  }

  void alarmSettings() {
    Future.delayed(
      const Duration(seconds: 15),
      () async {
        if ((connectedDevice?.isConnected ?? false) || isAlarmPlayed) {
          print('ececuting in alarm');
          return;
        }
        if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) {
          print('adapter state in alarm is $adapterState');
          emit(AutoDisconnectedState(connectedDevice?.platformName ?? ''));
        }
        isAlarmPlayed = true;
        await playAlarm();
        await getDevices();
        print("played from alarm");

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
    resultsStream?.cancel();
    audioPlayer.dispose();
    _connectionStateSubscription?.cancel();
    adapterStateStateSubscription.cancel();
    return super.close();
  }
}
