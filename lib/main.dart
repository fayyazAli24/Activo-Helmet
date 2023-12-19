import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilever_activo/app/get_it.dart';
import 'package:unilever_activo/app/initialize_app.dart';
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

Future<void> permissions() async {
  var androidInfo = await DeviceInfoPlugin().androidInfo;
  // var release = androidInfo.version.release; // Version number, example: Android 12
  var sdkInt = androidInfo.version.sdkInt; // SDK, example: 31
  // var manufacturer = androidInfo.manufacturer;
  // var model = androidInfo.model;
  if (sdkInt >= 30) {
    await Permission.manageExternalStorage.request();
  }

  await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.bluetoothScan,
    Permission.storage,
  ].request();
}

final di = GetIt.instance;
StreamSubscription? connectionStream;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await permissions();
    registerServices();
    final pref = await SharedPreferences.getInstance();
    await pref.clear();

    final isFirstRun = pref.getBool('firstRun');

    if (isFirstRun ?? true) {
      await pref.clear();
      await pref.setBool('firstRun', false);
    }

    connectionStream = Connectivity().onConnectivityChanged.listen(
      (event) async {
        if (event != ConnectivityResult.none) {
          final unSyncService = di.get<UnSyncRecordService>();

          await unSyncService.clearPreviousRecords();
          await unSyncService.clearUnsyncedReasonRecord();
          await unSyncService.clearUnsyncedAlertRecord();
        }
      },
      onDone: () async {
        await connectionStream?.cancel();
      },
    );
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
      ],
      child: const InitializeApp(),
    );
  }
}
