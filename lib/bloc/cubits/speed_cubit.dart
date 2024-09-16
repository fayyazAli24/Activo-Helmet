import 'package:geolocator/geolocator.dart';

class SpeedCubit {
  static double currentSpeed = 0.0;
  static void calculateSpeed() {
    Geolocator.getPositionStream().listen((position) {
      currentSpeed = position.speed * 3.6;
      print('is in testing $currentSpeed');
    });
  }
}
