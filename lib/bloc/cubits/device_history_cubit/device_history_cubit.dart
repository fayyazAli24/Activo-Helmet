import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class DeviceHistoryState {}

class InitialDeviceHistoryState extends DeviceHistoryState {}

class DeviceHistoryLoading extends DeviceHistoryState {}

class DeviceHistorySuccess extends DeviceHistoryState {
  List<DeviceReqBodyModel> deviceData = [];

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

      if (list != null) {
        List<DeviceReqBodyModel> decodedList =
            jsonDecode(list).map<DeviceReqBodyModel>((e) => DeviceReqBodyModel.fromJson(e)).toList();
        log("$decodedList");
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
