import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/states/device_history_state/device_history_state.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class DeviceHistoryCubit extends Cubit<DeviceHistoryState> {
  DeviceHistoryCubit() : super(InitialDeviceHistoryState());

  Future<void> deviceHistoryList() async {
    try {
      emit(DeviceHistoryLoading());
      final list = await StorageService().read(deviceListKey);
      if (list != null) {
        List<DeviceReqBodyModel> decodedList =
            jsonDecode(list).map<DeviceReqBodyModel>((e) => DeviceReqBodyModel.fromJson(e)).toList();
        print('$decodedList');
        emit(DeviceHistorySuccess(decodedList));
      } else {
        emit(DeviceHistoryFailed('Something went wrong'));
      }
    } catch (e) {
      print('$e');
      emit(DeviceHistoryFailed('Something went wrong'));
    }
  }
}
