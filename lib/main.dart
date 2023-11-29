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
import 'package:unilever_activo/bloc/cubits/splash_cubits/splash_cubit.dart';
import 'package:unilever_activo/bloc/cubits/theme_cubits/theme_cubit.dart';
import 'package:unilever_activo/domain/services/location_service.dart';

permissions() async {
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

  await di.get<LocationService>().getLocation();

  di.get<LocationService>().getLocationStream();

  final pref = await SharedPreferences.getInstance();

  final isFirstRun = await pref.getBool('firstRun');

  if (isFirstRun ?? true) {
    await pref.setBool('firstRun', false);
    await pref.clear();
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
      ],
      child: const InitializeApp(),
    );
  }
}
