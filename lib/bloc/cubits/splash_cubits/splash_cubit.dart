import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/main.dart';
import 'package:unilever_activo/navigations/app_routes.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';

class SplashCubit extends Cubit<int> {
  SplashCubit() : super(0);

  void initState() {
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        try {
          await di.get<LocationService>().getLocation();
          di.get<LocationService>().getLocationStream();
        } catch (e) {
          log('$e splash cubit');
        }
        pushNamedRemoveAll(AppRoutes.home);
      },
    );
  }
}
