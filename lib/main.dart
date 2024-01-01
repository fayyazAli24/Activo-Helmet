import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:unilever_activo/app/get_it.dart';
import 'package:unilever_activo/app/initialize_app.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_cubit.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/device_history_cubit/device_history_cubit.dart';
import 'package:unilever_activo/bloc/cubits/internnet_cubits/internet_cubit.dart';
import 'package:unilever_activo/bloc/cubits/location_cubits/location_cubit.dart';
import 'package:unilever_activo/bloc/cubits/location_history_cubit/location_history_cubit.dart';
import 'package:unilever_activo/bloc/cubits/splash_cubits/splash_cubit.dart';
import 'package:unilever_activo/bloc/cubits/switch_cubit/switch_cubit.dart';
import 'package:unilever_activo/bloc/cubits/theme_cubits/theme_cubit.dart';
import 'package:unilever_activo/bloc/cubits/timer_cubit/timer_cubit.dart';
import 'package:unilever_activo/domain/services/unsynce_record_service.dart';

final di = GetIt.instance;
StreamSubscription? connectionStream;
StreamSubscription<AlarmSettings>? alarmStream;
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

Future<bool> onNotifications() async {
  // Only available for flutter 3.0.0 and later
  // DartPluginRegistrant.ensureInitialized();

  // bring to foreground

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

  //only this one
  print('before stream');

  try {
    // alarmStream = Alarm.ringStream.stream.listen((event) async {
    // Is this running in background?

    final detroit = tz.getLocation('Asia/Karachi');
    print('${detroit.name}');
    await _localNotifications.zonedSchedule(
      1, // Notification ID
      title, // Notification Title
      'Please Wear Helmet',

      tz.TZDateTime(detroit, 2024, 01, 01, 13, 20),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      // Notification Body
      platformChannelSpecifics,
      payload: 'item x',
    );
    print('stream listening');
    // });
  } catch (e, s) {
    print(s);
    print(e);
  }

  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await permissions();

    registerServices();
    initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

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
    await Alarm.init();

    await checkIsFirstRun();
    await clearPreviousRecord();
    await onNotifications();
  } catch (e) {
    log('$e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppThemeModeCubit(),
        ),
        BlocProvider(
          create: (context) => TimerCubit(),
        ),
        BlocProvider(
          create: (context) => SplashCubit(),
        ),
        BlocProvider(
          create: (context) => BluetoothCubit(),
        ),
        BlocProvider(
          create: (context) => InternetCubit(),
        ),
        BlocProvider(
          create: (context) => LocationHistoryCubit(),
        ),
        BlocProvider(
          create: (context) => LocationCubit(),
        ),
        BlocProvider(
          create: (context) => DeviceHistoryCubit(),
        ),
        BlocProvider(
          create: (context) => SwitchCubit(),
        ),
        BlocProvider(
          create: (context) => AlarmCubit(),
        ),
      ],
      child: const InitializeApp(),
    );
  }
}
