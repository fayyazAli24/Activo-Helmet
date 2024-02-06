import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:location/location.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

import '../../app/app.dart';
import 'location_service.dart';

class HelmetService {
  Location location = Location();

  Future<dynamic> sendData(String helmetName, double batterPercent, int isWore) async {
    try {
      location.enableBackgroundMode(enable: true);
      final locationService = await location.getLocation();
      print('the location is $locationService');
      var deviceDataList = <DeviceReqBodyModel>[];
      String? encodedList = await StorageService().read(deviceListKey);
      if (encodedList != null) {
        deviceDataList =
            jsonDecode(encodedList).map<DeviceReqBodyModel>((e) => DeviceReqBodyModel.fromJson(e)).toList();
      }
      final speed = (locationService.speed! * 3.6);
      final reqModel = DeviceReqBodyModel(
        helmetId: helmetName,
        apiDateTime: DateTime.now(),
        userId: '',
        latitude: locationService.latitude,
        longitude: locationService.longitude,
        isWearHelmet: isWore,
        isWrongWay: 0,
        speed: speed,
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
    } catch (e) {
      log('$e');

      return null;
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
      print('unsycned data list is ${unsyncedDataList.first.userId}');
      final res = await ApiServices().post(api: Api.trJourney, body: unsyncedDataList);

      if (res != null) {
        for (var unsyncedModel in unsyncedDataList) {
          unsyncedModel.synced = 1;
          // unsyncedModel.apiDateTime = DateTime.now();
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
      final locationService = await di.get<LocationService>().getLocation();
      // location.enableBackgroundMode(enable: true);
      // final locationService = await location.getLocation();

      log('$reasonCode code');
      final body = {
        'Helmet_ID': helmetName,
        'Disconnect_Reason_Code': reasonCode.toString(),
        'Disconect_Time': DateTime.now().toIso8601String(),
        'Latitude': locationService.latitude,
        'Longitude': locationService.longitude,
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
      } else {
        final alertList = await StorageService().read(unSyncedAlertData);

        if (alertList != null) {
          var list =
              List<Map<String, dynamic>>.from(jsonDecode(alertList).map((e) => Map<String, dynamic>.from(e))).toList();

          list.add(body);
          await StorageService().write(unSyncedAlertData, jsonEncode(list));
        } else {
          await StorageService().write(unSyncedAlertData, jsonEncode([body]));
        }
      }
    } catch (e) {
      log('$e');
    }
  }

  Future<void> disconnectingReason(String helmetName, String reason, String desc) async {
    var date = DateTime.now().toIso8601String();
    var newDate = date.substring(0, date.length - 4);
    print('the new date is $newDate');
    try {
      var body = <String, dynamic>{
        'Helmet_ID': helmetName,
        'USER_ID': '',
        'DATE': newDate,
        'REASON': reason,
        'STATUS_DESC': desc,
      };

      print('the body of disconnecting alert is $body');

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
