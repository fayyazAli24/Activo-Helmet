import 'dart:convert';

import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';

class HelmetService {
  Future<dynamic> sendData(String helmetName, double batterPercent, int isWore) async {
    final locationService = di.get<LocationService>();
    var deviceDataList = <DeviceReqBodyModel>[];
    String? encodedList = await StorageService().read(deviceListKey);
    if (encodedList != null) {
      deviceDataList = jsonDecode(encodedList).map<DeviceReqBodyModel>((e) => DeviceReqBodyModel.fromJson(e)).toList();
    }

    final reqModel = DeviceReqBodyModel(
      helmetId: helmetName,
      userId: '',
      latitude: locationService.lat,
      longitude: locationService.long,
      isWearHelmet: isWore,
      apiDateTime: DateTime.now(),
      isWrongWay: 0,
      speed: locationService.speed,
      vehicleType: '',
      synced: 0,
      createdBy: '',
      updatedBy: '',
    );

    deviceDataList.add(reqModel);
    await StorageService().write(deviceListKey, jsonEncode(deviceDataList));

    final list = await syncUnsyncedData();
    if (list != null) {
      return [];
    } else {
      return null;
    }
  }

  Future<List<dynamic>?> syncUnsyncedData() async {
    var unsyncedDataList = <DeviceReqBodyModel>[];
    var dataList = <DeviceReqBodyModel>[];

    String? encodedList = await StorageService().read(deviceListKey);

    if (encodedList != null) {
      dataList = jsonDecode(encodedList).map<DeviceReqBodyModel>((e) => DeviceReqBodyModel.fromJson(e)).toList();
      unsyncedDataList = dataList.where((element) => element.synced == 0).toList();
    }

    if (unsyncedDataList.isEmpty) return null;

    try {
      final res = await ApiServices().post(api: Api.trJourney, body: unsyncedDataList);

      if (res != null) {
        for (var unsyncedModel in unsyncedDataList) {
          unsyncedModel.synced = 1;
        }
      } else {
        throw Exception('API call failed during unsynced data sync');
      }
    } catch (e) {
      print('API call failed during unsynced data sync: $e');
      throw Exception('API call failed during unsynced data sync');
    }

    ///updating local list
    for (final updatedModel in dataList) {
      final index = dataList.indexWhere((element) => element == updatedModel);
      if (index != -1) {
        dataList[index] = updatedModel;
      }
    }
    await StorageService().write(deviceListKey, jsonEncode(dataList));
    return [];
  }

  Future<void> disconnectingAlert(
    String helmetName,
    int reasonCode,
  ) async {
    try {
      final locationService = di.get<LocationService>();

      final body = {
        'Helmet_ID': helmetName,
        'Disconnect_Reason_Code': reasonCode.toString(),
        'Disconect_Time': DateTime.now().toIso8601String(),
        'Latitude': locationService.lat,
        'Longitude': locationService.long,
        'User_Id': 'awais',
        'Vehicle_Type': 'NA',
        'Created_By': 'awais',
        'Updated_By': 'awais',
      };

      final res = await ApiServices().post(api: Api.disconnectingAlert, body: body);

      if (res != null) {
        print('$res');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disconnectingReason(String helmetName) async {
    try {
      final body = {
        'Helmet_ID': helmetName,
        'USER_ID': 'awais',
        'Disconect_Time': DateTime.now().toIso8601String(),
      };

      final res = await ApiServices().post(api: Api.disconnectReason, body: body);

      if (res != null) {
        print('$res');
      }
    } catch (e) {
      rethrow;
    }
  }
}
