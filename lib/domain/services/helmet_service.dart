import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';

class HelmetService {
  StreamSubscription<Position>? locationStream;
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
      isWrongWay: 0,
      speed: locationService.speed,
      vehicleType: '',
      savedTime: DateTime.now(),
      synced: 0,
      createdBy: '',
      updatedBy: '',
    );

    deviceDataList.add(reqModel);
    await StorageService().write(deviceListKey, jsonEncode(deviceDataList));
    final isInternetAvailable = await Connectivity().checkConnectivity();
    if (isInternetAvailable != ConnectivityResult.none) {
      final list = await syncUnsyncedData();
      if (list != null) {
        return [];
      } else {
        return null;
      }
    }
    return null;
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
          unsyncedModel.apiDateTime = DateTime.now();
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

      log('$reasonCode code');
      final body = {
        'Helmet_ID': helmetName,
        'Disconnect_Reason_Code': reasonCode.toString(),
        'Disconect_Time': DateTime.now().toIso8601String(),
        'Latitude': locationService.lat,
        'Longitude': locationService.long,
        'User_Id': '',
        'Vehicle_Type': 'NA',
        'Created_By': '',
        'Updated_By': '',
      };

      final connection = await Connectivity().checkConnectivity();
      if (connection != ConnectivityResult.none) {
        final res = await ApiServices().post(api: Api.disconnectingAlert, body: [body]);
        if (res != null) {
          return res;
        }
      }
    } catch (e) {
      log('$e');
    }
  }

  Future<void> disconnectingReason(String helmetName, String reason, String desc) async {
    try {
      var body = <String, dynamic>{
        'Helmet_ID': helmetName,
        'USER_ID': '',
        'DATE': DateTime.now().toIso8601String(),
        'REASON': reason,
        'STATUS_DESC': desc,
      };

      final isInternetAvailable = await Connectivity().checkConnectivity();
      if (isInternetAvailable == ConnectivityResult.none) {
        body['sync'] = false;

        final reasonDataList = await StorageService().read(unSyncedReasonData);

        if (reasonDataList != null) {
          var list =
              List<Map<String, dynamic>>.from(jsonDecode(reasonDataList).map((e) => Map<String, dynamic>.from(e)))
                  .toList();

          list.add(body);
          await StorageService().write(unSyncedReasonData, jsonEncode(list));
        } else {
          await StorageService().write(unSyncedReasonData, jsonEncode([body]));
        }
      } else {
        final res = await ApiServices().post(api: Api.disconnectReason, body: [body]);
        if (res != null) {
          print('$res');
        }
      }
    } catch (e) {
      log('$e');
    }
  }
}
