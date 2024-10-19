import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/navigations/app_routes.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';

class SplashCubit extends Cubit<int> {
  SplashCubit() : super(0);

  void initState() {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        pushNamedRemoveAll(AppRoutes.home_page);
      },
    );
  }
}
