import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
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

  void checkConnectivity() {
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

  @override
  Future<void> close() async {
    await subscription?.cancel();
    return super.close();
  }
}
