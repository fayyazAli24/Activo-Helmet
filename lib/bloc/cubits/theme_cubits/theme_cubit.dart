import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/utils/app_colors.dart';

enum AppThemeMode { system, light, dark }

class AppThemeModeCubit extends Cubit<AppThemeMode> {
  AppThemeModeCubit() : super(AppThemeMode.system);
  bool? darkTheme;

  changeTheme(bool newTheme) {
    darkTheme = newTheme;
    if (darkTheme ?? false) {
      emit(AppThemeMode.dark);
    } else {
      emit(AppThemeMode.light);
    }
  }

  ThemeMode themeMode() {
    if (state == AppThemeMode.light) {
      return ThemeMode.light;
    } else if (state == AppThemeMode.dark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  ThemeData appTheme() {
    if (state == AppThemeMode.dark) {
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
    } else {
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
    }
  }
}
