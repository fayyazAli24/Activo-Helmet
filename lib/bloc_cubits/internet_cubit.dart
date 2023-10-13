import 'dart:async';
import 'dart:ffi';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum InternetState {
  initial,
  connected,
  disconnected,
}

class InternetCubit extends Cubit<InternetState> {
  InternetCubit() : super(InternetState.initial) {
    checkConnectivity();
  }

  StreamSubscription<ConnectivityResult>? subscription;

  checkConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (event) {
        if (event == ConnectivityResult.none) {
          emit(InternetState.disconnected);
        } else {
          emit(InternetState.connected);
        }
      },
      onDone: () {
        subscription?.cancel();
      },
    );
  }
}
