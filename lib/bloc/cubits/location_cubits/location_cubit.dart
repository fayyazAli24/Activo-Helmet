import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';

class LocationStatus {}

class LocationOn extends LocationStatus {}

class LocationOff extends LocationStatus {}

class LocationCubit extends Cubit<LocationStatus> {
  LocationCubit() : super(LocationStatus()) {
    checkLocation();
  }

  StreamSubscription<ServiceStatus>? subscription;
  Geolocator? geolocator;
  StreamSubscription<Geolocator>? geoLocationStream;
  checkLocation() async {
    subscription = Geolocator.getServiceStatusStream().listen(
      (newState) async {
        log("${newState} location state");
        if (newState == ServiceStatus.disabled) {
          emit(LocationOff());
        } else if (newState == ServiceStatus.enabled) {
          emit(LocationOn());
        }
      },
      onDone: () async {
        await subscription?.cancel();
      },
    );
  }

  openSettings() async {
    final isOn = await Geolocator.openLocationSettings();
    if (isOn) {
      pop();
      emit(LocationOn());
    } else {
      emit(LocationOff());
    }
  }

  resetState() {
    pop();
  }

  @override
  Future<void> close() async {
    await subscription?.cancel();

    return super.close();
  }
}
