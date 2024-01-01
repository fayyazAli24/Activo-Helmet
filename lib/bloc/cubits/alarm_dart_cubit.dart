import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:bloc/bloc.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_state.dart';
import 'package:unilever_activo/utils/assets.dart';

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit() : super(AlarmDartInitial()) {
    sortAlarms();
    // ringAlarm();
  }

  List<AlarmSettings> alarms = [];
  Future<void> sortAlarms() async {
    alarms = Alarm.getAlarms();
    alarms.sort(
      (a, b) => a.dateTime.isBefore(b.dateTime) ? -1 : 1,
    );
  }

  Future<void> setAlarm() async {
    final alarmSettings = AlarmSettings(
      id: 1,
      dateTime: DateTime(2024, 01, 01, 13, 20),
      loopAudio: false,
      volume: 0.1,
      vibrate: false,
      enableNotificationOnKill: false,
      assetAudioPath: AssetsPath.alarmSound,
      notificationTitle: 'Time to ride',
      notificationBody: 'Its time to wear helmet',
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  void ringAlarm() {
    emit(AlarmRingingState());
  }

  Future<void> stopAlarm() async {
    await Alarm.stop(1);
    emit(AlarmStoppedState());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
