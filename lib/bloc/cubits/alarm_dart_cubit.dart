import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:bloc/bloc.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_state.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit() : super(AlarmDartInitial()) {
    setAlarm(appAlarmTime);
    ringAlarm();
  }

  List<AlarmSettings> alarms = [];
  StreamSubscription<AlarmSettings>? alarmStream;
  late AlarmSettings alarmSettings;
  //
  // Future<void> sortAlarms() async {
  //   alarms = Alarm.getAlarms();
  //   alarms.sort(
  //     (a, b) => a.dateTime.isBefore(b.dateTime) ? -1 : 1,
  //   );
  // }

  Future<void> setAlarm(DateTime alarmTime) async {
    alarmSettings = AlarmSettings(
      id: 1,
      dateTime: alarmTime,
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

  Future<void> ringAlarm() async {
    alarmStream = Alarm.ringStream.stream.listen((event) {
      emit(AlarmRingingState());
    });
  }

  Future<void> stopAlarm() async {
    await Alarm.stop(1);

    emit(AlarmStoppedState());
  }

  @override
  Future<void> close() {
    alarmStream?.cancel();
    return super.close();
  }
}
