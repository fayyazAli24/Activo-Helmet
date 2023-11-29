import 'dart:convert';
import 'dart:developer';

import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';

class HelmetService {
  List<Map<String, dynamic>> deviceDataList = [];
  Future<dynamic> sendData(double speed, String helmetName, double batterPercent, int inWore) async {
    try {
      final locationService = di.get<LocationService>();
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

      deviceDataList.add(
        body,
      );

      await StorageService().write(deviceListKey, jsonEncode(deviceDataList));

      // // final res = await ApiServices().post(api: Api.trJourney, body: [body]);
      //
      // if (res != null) {
      //   return res;
      // }
      return null;
    } catch (e) {
      log("$e failed");
      rethrow;
    }
  }
}
