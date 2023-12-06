import 'package:geolocator/geolocator.dart';

class LocationService {
  double? lat;
  double? long;
  double? speed;

  Future<void> getLocation() async {
    try {
      final loc = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      speed = loc.speed * 3.6;
      lat = loc.latitude;
      long = loc.longitude;
    } catch (e) {
      print('$e)))');

      rethrow;
    }
  }

  Stream<Position> getLocationStream() {
    final loc = Geolocator.getPositionStream();
    return loc;
  }
}
