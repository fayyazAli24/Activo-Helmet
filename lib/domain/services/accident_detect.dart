import 'dart:math';

import 'package:another_telephony/telephony.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

import '../../app/app_keys.dart';

class AccidentDetectionService {
  static double gForceThreshold = 4.0; // Threshold for accident detection
  static final double g = 9.8; // Gravitational acceleration
  static double testGForce = 0.0;
  final Telephony telephony = Telephony.instance;
  Location location = Location();

  // Listen to Accelerometer Data
  void listenToAccelerometer() {
    accelerometerEventStream().listen((AccelerometerEvent event) async {
      // Calculate the magnitude of acceleration
      double a = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

      // Calculate G-force
      double gForce = a / g;
      testGForce = gForce;

      print('Acceleration Magnitude: $a, G-Force: $gForce');

      // Check if G-force exceeds threshold
      if (gForce > gForceThreshold) {
        print('Accident Detected! G-Force: $gForce');
        await accidentAlert();
      }
    });
  }

  String generateGoogleMapsLink(double latitude, double longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  Future<void> accidentAlert() async {
    /// call the email post api
    /// ---- API in making
    /// sending the sms
    /// falseCase = false;

    var number = await StorageService().read(sos);
    final locationService = await location.getLocation();
    String googleMapsLink = generateGoogleMapsLink(locationService.latitude!, locationService.longitude!);
    String emegencyMessage = '''Accident Occured !!\ntap on the link for accident location\n$googleMapsLink''';

    if (number != null) {
      if (await Permission.sms.request().isGranted) {
        await telephony.sendSms(to: number, message: emegencyMessage);
      } else {
        print('SMS permission denied');
      }
      await FlutterPhoneDirectCaller.callNumber(number);
    } else {
      print('Please add number in the SOS');
    }
  }
}
