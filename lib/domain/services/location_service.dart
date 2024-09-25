import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class LocationService {
  Future<Position> getLocation() async {
    try {
      late LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: true,
          // intervalDuration: const Duration(seconds: 15),
        );
      }
      final loc = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return loc;
    } catch (e) {
      log('get location : $e');
      throw Exception('$e');
    }
  }

  String getReason(int code) {
    if (code == 111) {
      return 'location off';
    }
    if (code == 222) {
      return 'Bluetooth';
    } else if (code == 333) {
      return 'Helmet Permission';
    } else if (code == 444) {
      return 'Helmet Disconnect';
    } else if (code == 555) {
      return 'User Disconnect';
    } else if (code == 666) {
      return 'App Exited';
    }
    return '';
  }

  Future<void> locationOn() async {
    await Permission.locationAlways.request();
  }

  Future<void> maintainLocationHistory(int reasonCode) async {
    if (reasonCode == 0) return;

    final record = await StorageService().read(disconnectTimeKey);
    print("heeh $record");
    final location = await getLocation();
    var list = <Map<String, dynamic>>[];
    final reason = getReason(reasonCode);

    print('cheecking exit of app');

    final body = {
      'reason': reason,
      'time': DateTime.now().toIso8601String(),
      'long': location.longitude,
      'lat': location.latitude,
      'speed': location.speed,
    };

    if (record != null) {
      list = List<Map<String, dynamic>>.from(jsonDecode(record).map((e) => Map<String, dynamic>.from(e))).toList();
      list.add(body);
      await StorageService().write(disconnectTimeKey, jsonEncode(list));
    } else {
      list.add(body);
      await StorageService().write(disconnectTimeKey, jsonEncode(list));
    }
  }
}
