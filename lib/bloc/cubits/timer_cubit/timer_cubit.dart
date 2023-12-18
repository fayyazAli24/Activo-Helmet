import 'package:flutter_bloc/flutter_bloc.dart';

class TimerState {}

class TimerInitialState extends TimerState {}

class TimerCountingState extends TimerInitialState {
  String connectedTime;
  TimerCountingState(this.connectedTime);
}

class TimerCubit extends Cubit<TimerState> {
  TimerCubit() : super(TimerInitialState());

  String totalTime = '';
  String formatDuration(Duration duration) {
    // Format the duration as HH:MM:SS
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  void updateTimer(DateTime connectedTime) {
    Duration duration = DateTime.now().difference(connectedTime);
    totalTime = formatDuration(duration);
    emit(TimerCountingState(totalTime));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
