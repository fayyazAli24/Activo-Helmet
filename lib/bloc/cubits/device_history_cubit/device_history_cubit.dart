import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class DeviceHistoryState {}

class InitialDeviceHistoryState extends DeviceHistoryState {}

class DeviceHistoryLoading extends DeviceHistoryState {}

class DeviceHistorySuccess extends DeviceHistoryState {
  List<Map<String, dynamic>> deviceData = [];

  DeviceHistorySuccess(this.deviceData);
}

class DeviceHistoryFailed extends DeviceHistoryState {
  String message = "";

  DeviceHistoryFailed(this.message);
}

class DeviceHistoryCubit extends Cubit<DeviceHistoryState> {
  DeviceHistoryCubit() : super(InitialDeviceHistoryState());

  Future<void> devicesList() async {
    try {
      emit(DeviceHistoryLoading());

      final list = await StorageService().read(deviceListKey);
      log("$list");
      if (list != null) {
        List<Map<String, dynamic>> decodedList =
            jsonDecode(list).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        emit(DeviceHistorySuccess(decodedList));
      } else {
        emit(DeviceHistoryFailed("Something went wrong"));
      }
    } catch (e) {
      log("$e");
      emit(DeviceHistoryFailed("Something went wrong"));
    }
  }
}
