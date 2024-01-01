import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_state.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit() : super(AlarmDartInitial()) {
    sortAlarms();
    ringAlarm();
  }

  List<AlarmSettings> alarms = [];
  BluetoothConnection? connection;
  late AlarmSettings alarmSettings;
  Future<void> sortAlarms() async {
    alarms = Alarm.getAlarms();
    alarms.sort(
      (a, b) => a.dateTime.isBefore(b.dateTime) ? -1 : 1,
    );
  }

  Future<void> setAlarm(DateTime alarmTime) async {
    alarmSettings = AlarmSettings(
      id: 1,
      dateTime: alarmTime,
      loopAudio: false,
      volume: 0,
      vibrate: false,
      enableNotificationOnKill: false,
      assetAudioPath: AssetsPath.alarmSound,
      notificationTitle: 'Time to ride',
      notificationBody: 'Its time to wear helmet',
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> ringAlarm() async {
    alarmStream = Alarm.ringStream.stream.listen((event) {
      emit(AlarmRingingState());
    });
  }

  Future<void> stopAlarm() async {
    await Alarm.stop(1);
    appAlarmTime = appAlarmTime.add(const Duration(minutes: 1));
    setAlarm(appAlarmTime);
    Future.delayed(
      const Duration(minutes: 5),
      () async {
        if (connection?.isConnected ?? false) {
          appAlarmTime = appAlarmTime.subtract(const Duration(minutes: 5));
          appAlarmTime = appAlarmTime.add(const Duration(days: 1));

          await StorageService().write(savedAlarmTimeKey, appAlarmTime.toIso8601String());
        }
      },
    );

    emit(AlarmStoppedState());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
