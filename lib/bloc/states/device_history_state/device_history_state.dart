import 'package:unilever_activo/domain/models/device_req_body_model.dart';

class DeviceHistoryState {}

class InitialDeviceHistoryState extends DeviceHistoryState {}

class DeviceHistoryLoading extends DeviceHistoryState {}

class DeviceHistorySuccess extends DeviceHistoryState {
  List<DeviceReqBodyModel> deviceData = [];

  DeviceHistorySuccess(this.deviceData);
}

class DeviceHistoryFailed extends DeviceHistoryState {
  String message = '';

  DeviceHistoryFailed(this.message);
}
