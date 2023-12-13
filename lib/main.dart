import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/app/get_it.dart';
import 'package:unilever_activo/app/initialize_app.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/device_history_cubit/device_history_cubit.dart';
import 'package:unilever_activo/bloc/cubits/internnet_cubits/internet_cubit.dart';
import 'package:unilever_activo/bloc/cubits/location_cubits/location_cubit.dart';
import 'package:unilever_activo/bloc/cubits/splash_cubits/splash_cubit.dart';
import 'package:unilever_activo/bloc/cubits/switch_cubit/switch_cubit.dart';
import 'package:unilever_activo/bloc/cubits/theme_cubits/theme_cubit.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

Future<void> clearUnsyncedReasonRecord() async {
  try {
    final reasonDataList = await StorageService().read(unSyncedReasonData);
    if (reasonDataList != null) {
      var list =
          List<Map<String, dynamic>>.from(jsonDecode(reasonDataList).map((e) => Map<String, dynamic>.from(e))).toList();

      final res = await ApiServices().post(api: Api.disconnectReason, body: list);
      if (res != null) {
        await StorageService().delete(unSyncedReasonData);
        print('$res');
      }
    }
  } catch (e) {
    print('e $e');
  }
}

Future<void> clearPreviousRecords() async {
  final savedDate = await StorageService().read('date');
  if (savedDate != null) {
    final parsedDate = DateTime.parse(savedDate);
    final currentDate = DateTime.now();
    if (parsedDate.day != currentDate.day) {
      try {
        final list = await di.get<HelmetService>().syncUnsyncedData();
        if (list != null) {
          await StorageService().delete(deviceListKey);
        }
      } catch (e) {
        print('$e');
      }

      await StorageService().write('date', DateTime.now().toIso8601String());
    }
  } else {
    await StorageService().write('date', DateTime.now().toIso8601String());
  }
}

Future<void> permissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
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

    final isFirstRun = pref.getBool('firstRun');
    await pref.clear();

    if (isFirstRun ?? true) {
      await pref.clear();
      await pref.setBool('firstRun', false);
    }

    connectionStream = Connectivity().onConnectivityChanged.listen(
      (event) async {
        if (event != ConnectivityResult.none) {
          await clearPreviousRecords();
          await clearUnsyncedReasonRecord();
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
          create: (context) => SplashCubit(),
        ),
        BlocProvider(
          create: (context) => BluetoothCubit(),
        ),
        BlocProvider(
          create: (context) => InternetCubit(),
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
