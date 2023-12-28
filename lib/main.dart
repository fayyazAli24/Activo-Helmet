import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   try {
//     final String title = 'Connect Helmet Alert';
//     final String body = 'Please enter helmet';
//
//     // Display a local notification
//     AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       channelDescription: body,
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: '@mipmap/launcher_icon',
//     );
//     DarwinNotificationDetails iosPlatformChanelSpecifics = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentSound: true,
//     );
//     NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iosPlatformChanelSpecifics,
//     );
//
//     await FlutterLocalNotificationsPlugin().show(
//       1, // Notification ID
//       title, // Notification Title
//       body, // Notification Body
//       platformChannelSpecifics,
//       payload: 'item x',
//     );
//   } catch (e) {
//     print('$e notifications***');
//   }
// }

// Future<void> setUpNotifications() async {
//   // Request notification permission
//   final permissionStatus = await Permission.notification.isGranted;
//   if (permissionStatus) {
//     FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//     final settings = await firebaseMessaging.requestPermission();
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       FirebaseMessaging.onMessage.listen((event) {
//         handleBackgroundMessage(event);
//       });
//       FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//     }
//   } else {
//     await Permission.notification.request();
//     print('Notification permission not granted.');
//   }
// }

Future<void> notifications() async {
  String localTimeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
  DateTime dateTime = DateTime(2023, 12, 27, 19, 10);

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      payload: {},
      id: 1,
      channelKey: 'scheduled',
      title: 'Helmet Alert',
      body: 'Please connect helmet',
    ),
    schedule: NotificationCalendar(
      day: dateTime.day,
      month: dateTime.month,
      year: dateTime.year,
      second: dateTime.second,
      millisecond: dateTime.millisecond,
      timeZone: localTimeZone,
      repeats: false,
    ),
  );
}

void ringAlarm() {
  notifications();

  alarmStream ??= Alarm.ringStream.stream.listen(
    (settings) async {
      debugPrint('notifications_ringing');
    },
    cancelOnError: true,
    onDone: () {
      alarmStream?.cancel();
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    // AwesomeNotifications().initialize(
    //     // set the icon to null if you want to use the default app icon
    //     null,
    //     [
    //       NotificationChannel(
    //           channelGroupKey: 'basic_channel_group',
    //           channelKey: 'scheduled',
    //           /* same name */
    //           channelName: 'Basic notifications',
    //           channelDescription: 'Notification channel for basic tests',
    //           defaultColor: Color(0xFF9D50DD),
    //           ledColor: Colors.white)
    //     ],
    //     debug: true);

    await permissions();

    registerServices();

    await checkIsFirstRun();
    await Alarm.init();
    await clearPreviousRecord();
    // ringAlarm();
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
