import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/cubits/location_cubits/location_cubit.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

import 'location_service.dart';

class HelmetService {
  Location location = Location();
  LocationCubit locationCubit = LocationCubit();

  Future<dynamic> sendData(String helmetName, double batterPercent, int isWore) async {
    try {
      await enableBackgroundMode();
      final locationService = await location.getLocation();
      //  final test = await di.get<LocationService>().getLocation();
      print('the location is $locationService');
      var deviceDataList = <DeviceReqBodyModel>[];
      String? encodedList = await StorageService().read(deviceListKey);
      if (encodedList != null) {
        deviceDataList =
            jsonDecode(encodedList).map<DeviceReqBodyModel>((e) => DeviceReqBodyModel.fromJson(e)).toList();
      }

      var speed = (locationService.speed! * 3.6);
      LocationCubit locationCubit = LocationCubit();

      print("before setting ");
      print(LocationCubit.prevLong);
      print(LocationCubit.prevLat);

      // locationCubit.prevSpeed = speed;

      // manually getting speed
      print("before if bloc");
      print("-------" + LocationCubit.prevLat.toString());
      if (LocationCubit.prevLat != null && LocationCubit.prevLong != null) {
        print(" not null manually being calculated");
        var temp = calculateSpeed(
            locationService.latitude!, locationService.longitude!, LocationCubit.prevLat!, LocationCubit.prevLong!, 15);
        speed = temp;
      }

      // setting the value
      LocationCubit.prevLat = locationService.latitude;
      LocationCubit.prevLong = locationService.longitude;

      print("after setting ");
      print(LocationCubit.prevLong);
      print(LocationCubit.prevLat);

      print("the speed in init is $speed");
      // if (speed == 0) return;

      final reqModel = DeviceReqBodyModel(
        helmetId: helmetName,
        apiDateTime: DateTime.now(),
        userId: '',
        latitude: locationService.latitude,
        longitude: locationService.longitude,
        isWearHelmet: isWore,
        isWrongWay: 0,
        // speed: test.speed * 3.6,
        speed: speed > 75 ? 75 : speed,
        vehicleType: '',
        savedTime: DateTime.now(),
        synced: 0,
        createdBy: '',
        updatedBy: '',
      );
      print('model being added to local storage is $reqModel');
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
      // log('$e');

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
      print('unsynced data list latitude is ${jsonEncode(unsyncedDataList.first.toJson())}');
      final res = await ApiServices().post(api: Api.trJourney, body: unsyncedDataList);
      print("resppnse is in $res");

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
      final locationService = await di.get<LocationService>().getLocation();
      // log('$reasonCode code');

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
      print("the body of alert is $body");
      final connection = await Connectivity().checkConnectivity();
      if (connection != ConnectivityResult.none) {
        print("checkinf if connection");
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
      print("exception while sending data to server");
      // log('$e');
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
      // log('$e');
    }
  }

  Future<bool> enableBackgroundMode() async {
    bool _bgModeEnabled = await location.isBackgroundModeEnabled();
    if (_bgModeEnabled) {
      return true;
    } else {
      try {
        await Permission.location.request();
        await location.enableBackgroundMode();
      } catch (e) {
        debugPrint(e.toString());
      }
      try {
        await Permission.location.request();
        _bgModeEnabled = await location.enableBackgroundMode();
      } catch (e) {
        debugPrint(e.toString());
      }
      print(_bgModeEnabled);

      //True!
      return _bgModeEnabled;
    }
  }

  double calculateSpeed(
    double currentLat,
    double currentLong,
    double previousLat,
    double previousLon,
    double timeInSeconds,
  ) {
    const double R = 6371.0; // Earth's radius in kilometers
    double degToRad = pi / 180;

    double lat1 = previousLat * degToRad;
    double lon1 = previousLon * degToRad;
    double lat2 = currentLat * degToRad;
    double lon2 = currentLong * degToRad;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c; // Distance in kilometers

    // Convert time from seconds to hours
    double timeInHours = timeInSeconds / 3600;

    return distance / timeInHours; // Speed in kilometers per hour
  }
}
