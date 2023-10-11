import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unilever_activo/app/app.dart';

import 'package:unilever_activo/bloc_cubits/home_cubit.dart';
import 'package:unilever_activo/bloc_cubits/splash_cubit.dart';
import 'package:unilever_activo/bloc_cubits/theme_cubit.dart';

import 'package:unilever_activo/navigations/app_routes.dart';

permissions() async {
  await [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await permissions();
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
          create: (context) => HomeCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocConsumer<AppThemeModeCubit, AppMode>(
            listener: (context, state) {},
            builder: (context, state) {
              final themeCubit = context.read<AppThemeModeCubit>();
              return MaterialApp(
                theme: themeCubit.appTheme(),
                themeMode: themeCubit.themeMode(),
                darkTheme: ThemeData.dark(useMaterial3: true),
                debugShowCheckedModeBanner: false,
                navigatorObservers: [
                  NavigatorObserver(),
                ],
                navigatorKey: App.navigatorKey,
                onGenerateRoute: (settings) {},
                initialRoute: AppRoutes.splash,
                routes: AppRoutes.routes,
                builder: (context, child) {
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}
