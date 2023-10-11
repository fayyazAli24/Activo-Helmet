import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/utils/app_colors.dart';

enum AppMode { system, light, dark }

class AppThemeModeCubit extends Cubit<AppMode> {
  AppThemeModeCubit() : super(AppMode.system);
  bool? darkTheme;

  changeTheme(bool newTheme) {
    darkTheme = newTheme;
    if (darkTheme ?? false) {
      emit(AppMode.dark);
    } else {
      emit(AppMode.light);
    }
  }

  ThemeMode themeMode() {
    if (state == AppMode.light) {
      return ThemeMode.light;
    } else if (state == AppMode.dark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  ThemeData appTheme() {
    if (state == AppMode.light) {
      return ThemeData(
        appBarTheme: AppBarTheme(color: AppColors.appBarColor),
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          background: AppColors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.black,
          ),
        ),
      );
    } else {
      return ThemeData(
        appBarTheme: AppBarTheme(color: AppColors.appBarColor),
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          background: AppColors.black,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.white,
          ),
        ),
      );
    }
  }
}
