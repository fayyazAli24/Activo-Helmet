import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';

class LocationStatus {}

class LocationOn extends LocationStatus {}

class LocationOff extends LocationStatus {}

class LocationCubit extends Cubit<LocationStatus> {
  LocationCubit() : super(LocationStatus()) {
    checkLocation();
  }
  String? deviceName;
  StreamSubscription<ServiceStatus>? subscription;
  Geolocator? geolocator;
  int isWore = 0;
  static double? prevLong;
  static double? prevLat;

  void checkLocation() {
    try {
      subscription = Geolocator.getServiceStatusStream().listen(
        (locationState) async {
          if (locationState == ServiceStatus.disabled) {
            print('cheek');
            if (deviceName != null) {
              print('device name is ' + deviceName!);
              await di.get<HelmetService>().disconnectingAlert(deviceName ?? '', 111);
            }
            emit(LocationOff());
          } else if (locationState == ServiceStatus.enabled) {
            emit(LocationOn());
          }
        },
        cancelOnError: true,
        onDone: () async {
          await subscription?.cancel();
        },
      );
    } catch (e) {
      log('$e');
      subscription?.cancel();
    }
  }

  Future<void> turnOnLocation() async {
    await LocationService().locationOn();
  }

  void openSettings() async {
    final isOn = await Geolocator.openLocationSettings();
    if (isOn) {
      pop();
      emit(LocationOn());
    } else {
      emit(LocationOff());
    }
  }

  @override
  Future<void> close() async {
    await subscription?.cancel();
    return super.close();
  }
}
