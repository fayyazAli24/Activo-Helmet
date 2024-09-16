import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/unsynce_record_service.dart';

enum InternetState {
  initial,
  connected,
  disconnected,
}

class InternetCubit extends Cubit<InternetState> {
  InternetCubit() : super(InternetState.initial) {
    checkConnectivity();
  }

  StreamSubscription<List<ConnectivityResult>>? subscription;

  Future<void> checkConnectivity() async {
    final connection = await Connectivity().checkConnectivity();
    if (connection.contains(ConnectivityResult.none)) {
      emit(InternetState.disconnected);
    }
    subscription = Connectivity().onConnectivityChanged.listen(
      (event) async {
        if (event.contains(ConnectivityResult.none)) {
          await di.get<HelmetService>().syncUnsyncedData();
          await di.get<UnSyncRecordService>().syncUnsyncedAlertRecord(false);
          await di.get<UnSyncRecordService>().syncUnsyncedReasonRecord(false);

          emit(InternetState.connected);
        } else {
          emit(InternetState.disconnected);
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
