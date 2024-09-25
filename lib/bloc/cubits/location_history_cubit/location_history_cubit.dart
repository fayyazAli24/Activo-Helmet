import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/bloc/states/location_history_state/location_history_state.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class LocationHistoryCubit extends Cubit<LocationHistoryState> {
  LocationHistoryCubit() : super(LocationHistoryInitial());

  Future<List<Map<String, dynamic>>> getRecords() async {
    try {
      emit(LocationHistoryLoading());
      var newList = <Map<String, dynamic>>[];
      final updatedRecords = await StorageService().read(disconnectTimeKey);

      print("xxxxxxxxxxxxxxxxx $updatedRecords");
      if (updatedRecords != null) {
        newList = List<Map<String, dynamic>>.from(jsonDecode(updatedRecords).map((e) => Map<String, dynamic>.from(e)))
            .toList();
      }

      if (newList.isEmpty) {
        emit(LocationHistoryFailed(''));
      } else {
        emit(LocationHistorySuccess(newList));
      }
      return newList;
    } catch (e) {
      emit(LocationHistoryFailed('$e'));
      return [];
    }
  }
}
