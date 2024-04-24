import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/bloc/cubits/internnet_cubits/internet_cubit.dart';
import 'package:unilever_activo/bloc/cubits/theme_cubits/theme_cubit.dart';
import 'package:unilever_activo/navigations/app_routes.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

class InitializeApp extends StatefulWidget {
  const InitializeApp({
    super.key,
  });

  @override
  State<InitializeApp> createState() => _InitializeAppState();
}

class _InitializeAppState extends State<InitializeApp> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeModeCubit, AppThemeMode>(
      builder: (context, state) {
        final themeCubit = context.watch<AppThemeModeCubit>();
        return GetMaterialApp(
          theme: themeCubit.appTheme(),
          themeMode: themeCubit.themeMode(),
          darkTheme: ThemeData.dark(useMaterial3: true),
          debugShowCheckedModeBanner: false,
          navigatorObservers: [
            NavigatorObserver(),
          ],
          navigatorKey: App.navigatorKey,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          builder: (context, child) {
            return BlocListener<InternetCubit, InternetState>(
              listener: (context, state) {
                if (state == InternetState.disconnected) {
                  snackBar('No internet', context, color: AppColors.red, textColor: AppColors.white);
                }
              },
              child: child!,
            );
          },
        );
      },
    );
  }
}
