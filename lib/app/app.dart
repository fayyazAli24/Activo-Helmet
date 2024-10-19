import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/domain/services/unsynce_record_service.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

import '../domain/services/dateServices.dart';

final di = GetIt.instance;
StreamSubscription<List<ConnectivityResult>>? connectionStream;

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

Future<void> permissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.bluetoothScan,
    Permission.notification,
    Permission.storage,
    Permission.locationAlways
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

Future<void> manageAlarmTime() async {
  if (await Alarm.isRinging(1)) return;

  String? date = await di.get<DateService>().getDate();
  List<String>? temp = [];
  final dateNow = DateTime.now();
  DateTime firstTime;

  try {
    if (date != null) {
      temp = date.split(':');
      int hour = int.parse(temp[0]);
      int minutes = int.parse(temp[1]);
      await StorageService().write(hourFromApi, hour.toString());
      await StorageService().write(minutesFromApi, minutes.toString());
      firstTime = DateTime(dateNow.year, dateNow.month, dateNow.day, hour, minutes);

      print('${appAlarmTime.toIso8601String()}');
    } else {
      String tempHour = await StorageService().read(hourFromApi) ?? '9';
      String tempMinutes = await StorageService().read(minutesFromApi) ?? '0';

      int hour = int.parse(tempHour);
      int minutes = int.parse(tempMinutes);

      firstTime = DateTime(dateNow.year, dateNow.month, dateNow.day, hour, minutes);
    }

    if (firstTime.isAfter(dateNow)) {
      appAlarmTime = firstTime;
    } else {
      appAlarmTime = firstTime.add(const Duration(days: 1));
    }
  } catch (e) {
    print('server api is not working');
  }
  print('${appAlarmTime.toIso8601String()}');
}

Future<void> manageAlarmTimeAfterBluetooth() async {
  String? date = await di.get<DateService>().getDate();
  List<String>? temp = [];
  final dateNow = DateTime.now();
  DateTime firstTime;

  try {
    if (date != null) {
      temp = date.split(':');
      int hour = int.parse(temp[0]);
      int minutes = int.parse(temp[1]);
      await StorageService().write(hourFromApi, hour.toString());
      await StorageService().write(minutesFromApi, minutes.toString());
      firstTime = DateTime(dateNow.year, dateNow.month, dateNow.day, hour, minutes);

      print('${appAlarmTime.toIso8601String()}');
    } else {
      String tempHour = await StorageService().read(hourFromApi) ?? '9';
      String tempMinutes = await StorageService().read(minutesFromApi) ?? '0';

      int hour = int.parse(tempHour);
      int minutes = int.parse(tempMinutes);

      firstTime = DateTime(dateNow.year, dateNow.month, dateNow.day, hour, minutes);
    }

    if (firstTime.isAfter(dateNow)) {
      appAlarmTime = firstTime;
    } else {
      appAlarmTime = firstTime.add(const Duration(days: 1));
    }
  } catch (e) {
    print('server api is not working');
  }
  print('${appAlarmTime.toIso8601String()}');
}

Future<void> checkIsFirstRun() async {
  final pref = await SharedPreferences.getInstance();
  final isFirstRun = pref.getBool('firstRun');

  if (isFirstRun ?? true) {
    await pref.clear();
    await pref.setBool('firstRun', false);
  }
}

Future<void> clearPreviousRecord() async {
  connectionStream = Connectivity().onConnectivityChanged.listen(
    (event) async {
      if (event.contains(ConnectivityResult.wifi)) {
        print('in the condition');
        await di.get<UnSyncRecordService>().clearPreviousRecords();
      }
    },
    onDone: () async {
      await connectionStream?.cancel();
    },
  );
}

Future<void> setUpNotifications() async {
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

  if (await Alarm.isRinging(1)) {
    return;
  }

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
}

class App {
  static final navigatorKey = GlobalKey<NavigatorState>();
}
