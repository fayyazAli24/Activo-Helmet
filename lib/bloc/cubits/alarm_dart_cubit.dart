import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:bloc/bloc.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_state.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit() : super(AlarmDartInitial()) {
    setAlarm(appAlarmTime);
    ringAlarm();
  }

  List<AlarmSettings> alarms = [];

  late AlarmSettings alarmSettings;
  //
  // Future<void> sortAlarms() async {
  //   alarms = Alarm.getAlarms();
  //   alarms.sort(
  //     (a, b) => a.dateTime.isBefore(b.dateTime) ? -1 : 1,
  //   );
  // }

  Future<void> setAlarm(DateTime alarmTime) async {
    if (await Alarm.isRinging(1)) return;
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
    print('alarm set $alarmTime');
    emit(AlarmSetState());
  }

  Future<void> ringAlarm() async {
    Alarm.ringStream.stream.listen(
      (event) async {
        print('ringing ${event.id}');
        emit(AlarmRingingState());
      },
    );
  }

  Future<void> stopAlarm() async {
    final isStopped = await Alarm.stop(1);
    print('$isStopped');
    if (isStopped) {
      appAlarmTime = appAlarmTime.add(const Duration(minutes: 5));
      await setUpNotifications();
      await setAlarm(appAlarmTime);
      print('alarm time $appAlarmTime');
    }

    emit(AlarmStoppedState());
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
