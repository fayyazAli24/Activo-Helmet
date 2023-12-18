import 'dart:convert';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class LocationService {
  Future<Position> getLocation() async {
    try {
      final loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return loc;
    } catch (e) {
      log('get location : $e');
      throw Exception('$e');
    }
  }

  String getReason(int code) {
    if (code == 222) {
      return 'Bluetooth';
    } else if (code == 333) {
      return 'Helmet Permission';
    }
    return 'Helmet';
  }

  Future<void> maintainLocationHistory(int reasonCode) async {
    if (reasonCode == 111 || reasonCode == 0) return;

    final record = await StorageService().read(disconnectTimeKey);
    final location = await getLocation();
    var list = <Map<String, dynamic>>[];
    final reason = getReason(reasonCode);
    final body = {
      'reason': reason,
      'time': DateTime.now().toIso8601String(),
      'long': location.longitude,
      'lat': location.latitude,
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
