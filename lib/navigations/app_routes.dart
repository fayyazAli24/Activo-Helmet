import 'package:flutter/cupertino.dart';
import 'package:unilever_activo/screens/home/device_history_screen.dart';
import 'package:unilever_activo/screens/home/home_screen.dart';
import 'package:unilever_activo/screens/splash.dart';

class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const deviceHistory = '/device_history_screen';
  static Map<String, Widget Function(BuildContext _)> routes = {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    deviceHistory: (_) => const DeviceHistoryScreen()
  };
}
