import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/bloc/splash_cubit.dart';
import 'package:unilever_activo/navigations/app_routes.dart';

permissions() async {
  await [Permission.location, Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request();
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
          create: (context) => SplashCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
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
      ),
    );
  }
}
