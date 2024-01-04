import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unilever_activo/domain/services/unsynce_record_service.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

final di = GetIt.instance;
StreamSubscription<ConnectivityResult>? connectionStream;

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

Future<void> permissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.bluetoothScan,
    Permission.notification,
    Permission.storage,
  ].request();
}

void initializeNotifications() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  _localNotifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {},
  );
}

Future<void> manageAlarmTIme() async {
  final dateNow = DateTime.now();

  ///this time will come from API
  final firstTime = DateTime(dateNow.year, dateNow.month, dateNow.day, 9, 00);

  if (firstTime.isAfter(dateNow)) {
    appAlarmTime = firstTime;
  } else {
    appAlarmTime = firstTime.add(const Duration(days: 1));
  }

  print('${appAlarmTime.toIso8601String()}');
}

Future<void> checkIsFirstRun() async {
  final pref = await SharedPreferences.getInstance();

  final isFirstRun = pref.getBool('firstRun');
  await pref.clear();

  if (isFirstRun ?? true) {
    await pref.clear();
    await pref.setBool('firstRun', false);
  }
}

Future<void> clearPreviousRecord() async {
  connectionStream = Connectivity().onConnectivityChanged.listen(
    (event) async {
      if (event != ConnectivityResult.none) {
        await di.get<UnSyncRecordService>().clearPreviousRecords();
      }
    },
    onDone: () async {
      await connectionStream?.cancel();
    },
  );
}

Future<bool> setUpNotifications() async {
  final String title = 'Connect Helmet Alert';
  final String body = 'Please enter helmet';

  // Display a local notification
  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    channelDescription: body,
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/launcher_icon',
  );
  DarwinNotificationDetails iosPlatformChanelSpecifics = const DarwinNotificationDetails(
    presentAlert: true,
    presentSound: true,
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iosPlatformChanelSpecifics,
  );
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id', // id
    'MY FOREGROUND SERVICE', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max, // importance must be at low or higher level
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  try {
    await _localNotifications.zonedSchedule(
      1, // Notification ID
      title, // Notification Title
      body,
      tz.TZDateTime(
          tz.local, appAlarmTime.year, appAlarmTime.month, appAlarmTime.day, appAlarmTime.hour, appAlarmTime.minute),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      // Notification Body
      platformChannelSpecifics,
      payload: 'item x',
    );
  } catch (e, s) {
    print(s);
    print(e);
  }

  return true;
}

class App {
  static final navigatorKey = GlobalKey<NavigatorState>();
}
