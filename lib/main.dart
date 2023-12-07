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
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

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
      await StorageService().delete(lastDeviceKey);
      await StorageService().delete(autoConnectKey);

      await StorageService().write('date', DateTime.now().toIso8601String());
    }
  } else {
    await StorageService().write('date', DateTime.now().toIso8601String());
  }
}

Future<void> permissions() async {
  await [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();
}

final di = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await permissions();
  registerServices();
  final pref = await SharedPreferences.getInstance();

  await di.get<LocationService>().getLocation();
  di.get<LocationService>().getLocationStream();

  final isFirstRun = pref.getBool('firstRun');

  if (isFirstRun ?? true) {
    await pref.clear();
    await pref.setBool('firstRun', false);
  }

  await clearPreviousRecords();

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
