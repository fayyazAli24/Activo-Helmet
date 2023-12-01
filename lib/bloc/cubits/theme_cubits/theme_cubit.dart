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
        switchTheme: SwitchThemeData(
          trackColor: MaterialStatePropertyAll<Color>(
            AppColors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          color: AppColors.appBarColor,
          iconTheme: IconThemeData(
            color: AppColors.white,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          background: AppColors.black,
        ),
        cardTheme: CardTheme(surfaceTintColor: AppColors.black),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.white,
          ),
        ),
      );
    }
    return ThemeData(
      switchTheme: SwitchThemeData(
        trackColor: MaterialStatePropertyAll<Color>(
          AppColors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        color: AppColors.appBarColor,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      colorScheme: const ColorScheme.light(
        background: AppColors.white,
      ),
      cardTheme: CardTheme(surfaceTintColor: AppColors.white, elevation: 5),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.black,
        ),
      ),
    );
  }
}
