import 'dart:convert';
import 'dart:math';

import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';

class HelmetService {
  Future<dynamic> sendData(String helmetName, double batterPercent, int inWore) async {
    try {
      final locationService = di.get<LocationService>();
      double speed = 0.0;
      List<DeviceReqBodyModel> deviceDataList = [];
      String? encodedList = await StorageService().read(deviceListKey);
      if (encodedList != null) {
        deviceDataList =
            jsonDecode(encodedList).map<DeviceReqBodyModel>((e) => DeviceReqBodyModel.fromJson(e)).toList();

        ///calculate speed
        speed = calculateSpeed(deviceDataList.last.latitude!, deviceDataList.last.longitude!, locationService.lat!,
            locationService.long!, deviceDataList.last.apiDateTime!, DateTime.now());
      }

      final body = {
        "Helmet_ID": helmetName,
        "User_Id": "",
        "API_DateTime": DateTime.now().toIso8601String(),
        "Latitude": locationService.lat,
        "Longitude": locationService.long,
        "Is_Wear_Helmet": inWore,
        "Is_Wrong_Way": 0,
        "speed": speed,
        "VehicleType": "",
        "Created_By": "awais",
        "Updated_By": "awais"
      };

      final model = DeviceReqBodyModel.fromJson(body);
      deviceDataList.add(model);
      await StorageService().write(deviceListKey, jsonEncode(deviceDataList));
      final res = await ApiServices().post(api: Api.trJourney, body: [body]);
      if (res != null) {
        return res;
      }
      return null;
    } catch (e) {
      print("$e failed");
      rethrow;
    }
  }

  Future<void> disconnectingAlert(
    String helmetName,
    int reasonCode,
  ) async {
    try {
      final locationService = di.get<LocationService>();

      final body = {
        "Helmet_ID": helmetName,
        "Disconnect_Reason_Code": reasonCode.toString(),
        "Disconect_Time": DateTime.now().toIso8601String(),
        "Latitude": locationService.lat,
        "Longitude": locationService.long,
        "User_Id": "awais",
        "Vehicle_Type": "NA",
        "Created_By": "awais",
        "Updated_By": "awais",
      };

      final res = await ApiServices().post(api: Api.disconnectingAlert, body: body);

      if (res != null) {
        print("$res");
      }
    } catch (e) {}
  }

  Future<void> disconnectingReason(String helmetName) async {
    try {
      final body = {
        "Helmet_ID": helmetName,
        "USER_ID": "awais",
        "Disconect_Time": DateTime.now().toIso8601String(),
      };

      final res = await ApiServices().post(api: Api.disconnectReason, body: body);

      if (res != null) {
        print("$res");
      }
    } catch (e) {}
  }

  ///calculate speed
  double calculateDistance(
    double startLat,
    double startLong,
    double endLat,
    double endLong,
  ) {
    const R = 6371.0; // Radius of the Earth in kilometers

    double dLat = _toRadians(endLat - startLat);
    double dLon = _toRadians(endLong - startLong);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) * cos(_toRadians(endLat)) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c; // Distance in kilometers

    return distance;
  }

  double calculateSpeed(
      double startLat, double startLong, double endLat, double endLong, DateTime startTime, DateTime endTime) {
    double distance = calculateDistance(startLat, startLong, endLat, endLong);
    double timeInSeconds = endTime.difference(startTime).inSeconds.toDouble();

    double speed = (distance / timeInSeconds) * 3600.0; // Speed in kilometers per hour

    return speed;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }
}
