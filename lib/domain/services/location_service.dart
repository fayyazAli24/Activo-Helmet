import 'dart:developer';

import 'package:geolocator/geolocator.dart';

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
}
