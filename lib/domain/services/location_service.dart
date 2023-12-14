import 'dart:developer';

import 'package:geolocator/geolocator.dart';

class LocationService {
  double? lat;
  double? long;
  double? speed;

  Future<Position> getLocation() async {
    try {
      final loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      speed = loc.speed * 3.6;
      lat = loc.latitude;
      long = loc.longitude;
      return loc;
    } catch (e) {
      log('get location : $e');
      throw Exception('$e');
    }
  }
}
