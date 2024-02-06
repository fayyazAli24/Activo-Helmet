import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

import 'bloc/states/bluetooth_state/bluetooth_states.dart';
import 'domain/services/helmet_service.dart';

String? name1;
late BluetoothConnectedState state1;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart, onBackground: onIosBackground),
      androidConfiguration: AndroidConfiguration(onStart: onStart, isForegroundMode: true, autoStart: true));
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        print('foreground running');
      }
    }
    var res = await Geolocator.getCurrentPosition();
    print('the location is $res');
    print('running on background');

    print("value assigned to state1");

    var result = await HelmetService().sendData(name1 ?? '', state1.batteryPercentage, state1.isWore);
    if (result != null) {
      print('success');
      // snackBar('Data Synced Successfully', context);
    } else {
      print('fail');
      // snackBar('Data Failed To Synced', context);
    }

    service.invoke('update');
  });
}
