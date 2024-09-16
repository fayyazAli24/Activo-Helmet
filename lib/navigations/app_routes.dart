import 'package:flutter/cupertino.dart';
import 'package:unilever_activo/screens/bottom_navigation/landing_page.dart';
import 'package:unilever_activo/screens/home/drop_down/device_history_screen.dart';
import 'package:unilever_activo/screens/home/drop_down/location_history_screen.dart';
import 'package:unilever_activo/screens/home/home_screen.dart';
import 'package:unilever_activo/screens/splash.dart';

import '../screens/home/drop_down/calibrate_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const home_page = '/home_page';
  static const home = '/home';
  static const locationHistory = 'location_history_screen';
  static const deviceHistory = '/device_history_screen';
  static const calibrate = '/calibrate_screen';
  static Map<String, Widget Function(BuildContext _)> routes = {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    locationHistory: (_) => const LocationHistoryScreen(),
    deviceHistory: (_) => const DeviceHistoryScreen(),
    calibrate: (_) => const CalibrateScreen(),
    home_page: (_) => const HomePage()
  };
}
