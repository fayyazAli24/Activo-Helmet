import 'dart:async';
import 'dart:math';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

import '../../app/app_keys.dart';

class AccidentDetectionService {
  static double gForceThreshold = 3.0; // Threshold for accident detection
  static final double g = 9.8; // Gravitational acceleration
  static double testGForce = 0.0;
  final Telephony telephony = Telephony.instance;
  Location location = Location();

  // Listen to Accelerometer Data
  void listenToAccelerometer(BuildContext context) {
    accelerometerEventStream().listen((AccelerometerEvent event) async {
      double a = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      double gForce = a / g;
      testGForce = gForce;
      print('Acceleration Magnitude: $a, G-Force: $gForce');
      if (gForce > gForceThreshold) {
        print('Accident Detected! G-Force: $gForce');
        await accidentAlert(context);
      }
    });
  }

  String generateGoogleMapsLink(double latitude, double longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  Future<void> accidentAlert(BuildContext context) async {
    /// call the email post api
    /// ---- API in making
    /// sending the sms
    /// falseCase = false;

    var number = await StorageService().read(sos);
    final locationService = await location.getLocation();
    String googleMapsLink = generateGoogleMapsLink(locationService.latitude!, locationService.longitude!);
    String emegencyMessage = '''Accident Occured !!\ntap on the link for accident location\n$googleMapsLink''';

    if (number == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Contact Not Added'),
            content: const Text('Please add a contact number'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    if (number != null) {
      if (await Permission.sms.request().isGranted) {
        print("jjkjkjjjk");
        await telephony.sendSms(to: number, message: emegencyMessage);
        await FlutterPhoneDirectCaller.callNumber(number);
      } else {
        print('Please add number in the SOS');
      }
    }
  }
}
