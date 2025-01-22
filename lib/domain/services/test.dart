import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/cubits/timer_cubit/timer_cubit.dart';

class TimerTest {
  static late DateTime connectedTime;
  static Timer? counter;
  static bool start = false;
  static StreamSubscription? streamSubscription;

  static void manageCounter(BuildContext context) {
    if (start) {
      connectedTime = DateTime.now();
      context.read<TimerCubit>().updateTimer(connectedTime);
      counter = Timer.periodic(const Duration(seconds: 1), (value) {
        context.read<TimerCubit>().updateTimer(connectedTime);
      });
    }
  }
}
