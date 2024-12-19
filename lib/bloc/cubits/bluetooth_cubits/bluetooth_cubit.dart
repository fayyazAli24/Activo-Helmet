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
import 'package:unilever_activo/domain/services/test.dart';
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
  int cheek = 0;
  int count = 0;
  bool checkLocation = false;
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
  StreamSubscription<ServiceStatus>? subscription;

  Future<void> checkPermissions() async {
    final bluetoothPermission = await Permission.bluetooth.isGranted;
    final locationPermission = await Permission.location.isGranted;
    // PermissionStatus status;

    if (!bluetoothPermission) {
      print('not bluetooth');
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
        print('in else if');
        emit(BluetoothStateOn());
        print('from listen state');
        await getDevices();
      }
    });

    // adapterStateStateSubscription.cancel();
  }

  Future<void> test() async {
    await Future.delayed(const Duration(seconds: 5));
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
      print('in get device $adapterState');
      if (adapterState == BluetoothAdapterState.on) {
        print("thisssssssssssss");
        isDiscovering = true;
        scannedDevices = [];
        emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
        await FlutterBluePlus.startScan();
        resultsStream = FlutterBluePlus.scanResults.listen(
          (event) async {
            for (ScanResult result in event) {
              if (!scannedDevices.contains(result.device) && (result.device.platformName.isNotEmpty)) {
                print('the resultant devices are ${result.device.platformName}');
                scannedDevices.add(result.device);
                if (autoConnected) {
                  print("theeeeeeeeeee");
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
        print('in else');
        isDiscovering = false;
        Permission.bluetooth.request();
      }
    } catch (e) {
      print("in catch block");
      await FlutterBluePlus.stopScan();
      isDiscovering = false;
      scannedDevices = [];
      emit(BluetoothScannedState(devices: scannedDevices, isDiscovering: isDiscovering));
      print('the error is $e');
    }
  }

  Future<BluetoothDevice?> search(String id) async {
    print('searching here');
    for (int i = 0; i < scannedDevices.length; i++) {
      print("the naming is ${scannedDevices[i].platformName}");
      if (scannedDevices[i].platformName == id) {
        print("found the device");
        return scannedDevices[i];
      }
    }
    return null;
  }

  BluetoothDevice? searchDevice(String deviceName) {
    for (int i = 0; i < scannedDevices.length; i++) {
      if (scannedDevices[i].platformName == deviceName) {
        return scannedDevices[i];
      }
    }
    return null;
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      final connection = await checkConnections();
      if (connection != null) {
        emit(BluetoothFailedState(message: 'Failed to connect'));
        print('scanning');
        // await getDevices();
        return;
      }
      emit(BluetoothConnectingState());
      connectedDevice = device;
      await FlutterBluePlus.stopScan();

      print('the device is $connectedDevice');
      await device.connect();

      TimerTest.start = true;

      await Future.delayed(Duration(seconds: 3));
      if (connectedDevice?.isConnected ?? false) {
        final convertedDevice = connectedDevice?.platformName;
        await StorageService().write(lastDeviceKey, convertedDevice ?? '');
        deviceName = device.platformName;

        await StorageService().write(connectTimeKey, DateTime.now().toIso8601String());

        var temp = await StorageService().read(connectTimeKey);
        print('device saved $temp');

        services = await device.discoverServices();

        for (int i = 0; i < services.length; i++) {
          print('the services is ${services[i]}');
        }

        // Find the service and characteristic

        try {
          _connectionStateSubscription = device.connectionState.listen((BluetoothConnectionState state) async {
            if (state == BluetoothConnectionState.connected) {
              /// battery service
              BluetoothService batteryService = services.firstWhere(
                (service) => service.uuid.toString() == '180f',
                orElse: () => throw Exception('Battery Service not found'),
              );

              /// battery characteristics

              BluetoothCharacteristic batteryCharacteristic = batteryService.characteristics.firstWhere(
                (characteristic) => characteristic.uuid.toString() == '2a19',
                orElse: () => throw Exception('Battery Characteristic not found'),
              );

              final batterySub = batteryCharacteristic.lastValueStream.listen((value) {
                print('the stream is $value');
                if (value.isNotEmpty) {
                  // Assuming the first byte represents the battery level
                  batteryPercentage = value[0].toDouble();
                  print('Battery Level: $batteryPercentage%');

                  emit(BluetoothConnectedState(
                      deviceName: device.platformName,
                      batteryPercentage: batteryPercentage ?? 0.0,
                      isWore: isWore,
                      cheek: cheek,
                      speed: 0));
                } else {
                  batteryPercentage = 0.0;
                  print('No data received');
                }
              });

              await batteryCharacteristic.setNotifyValue(true);
              device.cancelWhenDisconnected(batterySub);

              BluetoothService sensorService2 = services.firstWhere(
                (service) => service.uuid.toString() == '4fafc201-1fb5-459e-8fcc-c5c9c331914b',
                orElse: () => throw Exception('Sensor 2 Service not found'),
              );

              BluetoothService sensorService3 = services.firstWhere(
                (service) => service.uuid.toString() == '4fafc201-1fb5-459e-8fcc-c5c9c331914c',
                orElse: () => throw Exception('Sensor 3 Service not found'),
              );

              BluetoothCharacteristic sensorCharacteristic2 = sensorService2.characteristics.firstWhere(
                (characteristic) => characteristic.uuid.toString() == 'e5944ed2-a415-420a-93a0-ecbfc372ac96',
                orElse: () => throw Exception('Sensor 2 Characteristic not found'),
              );

              BluetoothCharacteristic sensorCharacteristic3 = sensorService3.characteristics.firstWhere(
                (characteristic) => characteristic.uuid.toString() == '8ee13963-8d1c-428d-8654-77b20850f393',
                orElse: () => throw Exception('Sensor 3 Characteristic not found'),
              );

              // Enable notifications for the second sensor
              final sensorSub2 = sensorCharacteristic2.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  isWore = value[0];
                  count++;
                  print('Sensor 2 Data: $value');
                  // Convert and use the data as needed
                } else {
                  isWore = 0;
                  print('No data received from Sensor 2');
                }
                emit(BluetoothConnectedState(
                    deviceName: device.platformName,
                    batteryPercentage: batteryPercentage ?? 0.0,
                    isWore: isWore,
                    cheek: cheek,
                    speed: 0,
                    count: count));
              });
              sensorCharacteristic2.setNotifyValue(true);
              device.cancelWhenDisconnected(sensorSub2);

              final sensorSub3 = sensorCharacteristic3.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  // isWore = value[0];
                  count++;
                  cheek = value[0];
                  print('Sensor 3 Data: $value');
                } else {
                  // isWore = 0;
                  cheek = 0;
                  print('No data received from Sensor 3');
                }
                emit(BluetoothConnectedState(
                    deviceName: device.platformName,
                    batteryPercentage: batteryPercentage ?? 0.0,
                    isWore: isWore,
                    cheek: cheek,
                    speed: 0,
                    count: count));
              });
              sensorCharacteristic3.setNotifyValue(true);
              device.cancelWhenDisconnected(sensorSub3);
            } else if (state == BluetoothConnectionState.disconnected) {
              checkLocation = false;
              await test();
            }
          });
          device.cancelWhenDisconnected(_connectionStateSubscription!, delayed: true, next: true);
        } catch (e) {}

        pop();
        emit(
          BluetoothConnectedState(
              speed: pressure ?? 0.0,
              deviceName: deviceName ?? '',
              batteryPercentage: batteryPercentage ?? 0.0,
              isWore: isWore,
              cheek: cheek),
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

    await StorageService().write(disconnectReasonKey, reason.toString());

    TimerTest.start = false;
    // TimerTest.counter = null;
    connectedDevice?.disconnect();
    subscription?.cancel();
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
      print('---in disconnected alert');
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
          print('executing in alarm');
          return;
        }
        if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) {
          print('adapter state in alarm is $adapterState');
          emit(AutoDisconnectedState(connectedDevice?.platformName ?? ''));
        }
        isAlarmPlayed = true;
        await playAlarm();
        await getDevices();
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
