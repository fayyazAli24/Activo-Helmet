import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/app/get_it.dart';
import 'package:unilever_activo/app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await permissions();
    registerServices();
    initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
    await Alarm.init();
    // await initializeService();
    await checkIsFirstRun();
    await manageAlarmTime();
    initializeNotifications();
    await setUpNotifications();
    await clearPreviousRecord();
  } catch (e) {
    log('$e');
  }

  runApp(const MyApp());
}
