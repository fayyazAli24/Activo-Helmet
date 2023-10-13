import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';

enum LocationStatus { initial, on, off }

class LocationCubit extends Cubit<LocationStatus> {
  LocationCubit() : super(LocationStatus.initial) {
    checkLocation();
  }

  Geolocator? geolocator;
  StreamSubscription<Geolocator>? geoLocationStream;
  checkLocation() async {
    Geolocator.getServiceStatusStream().listen((newState) async {
      log("${newState} location state");
      if (newState == ServiceStatus.disabled) {
        emit(LocationStatus.off);
      } else if (newState == ServiceStatus.enabled) {
        emit(LocationStatus.on);
      }
    });
  }

  openSettings() async {
    final isOn = await Geolocator.openLocationSettings();
    if (isOn) {
      pop();
      emit(LocationStatus.on);
    } else {
      emit(LocationStatus.off);
    }
  }

  resetState() {
    pop();
    emit(LocationStatus.off);
  }
}
