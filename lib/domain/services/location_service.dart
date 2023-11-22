import 'package:geolocator/geolocator.dart';

class LocationService {
  double? lat;
  double? long;

  Future<void> getLocation() async {
    final loc = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    lat = loc.latitude;
    long = loc.longitude;
  }

  Stream<Position> getLocationStream() {
    final loc = Geolocator.getPositionStream();
    return loc;
  }
}
