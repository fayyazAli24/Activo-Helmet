import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';

class LocationHistoryState {}

class LocationHistoryInitial extends LocationHistoryState {}

class LocationHistoryLoading extends LocationHistoryState {}

class LocationHistorySuccess extends LocationHistoryState {
  var list = <Map<String, dynamic>>[];

  LocationHistorySuccess(this.list);
}

class LocationHistoryFailed extends LocationHistoryState {
  String? message;
  LocationHistoryFailed(this.message);
}

class LocationHistoryCubit extends Cubit<LocationHistoryState> {
  LocationHistoryCubit() : super(LocationHistoryInitial());

  String getReason(int code) {
    if (code == 222) {
      return 'Bluetooth';
    } else if (code == 333) {
      return 'Helmet Permission';
    }
    return 'Helmet';
  }

  Future<List<Map<String, dynamic>>> maintainLocationHistory(int reasonCode) async {
    if (reasonCode != 444 || reasonCode != 222 || reasonCode != 333) return [];
    final record = await StorageService().read(disconnectTimeKey);
    final location = await di.get<LocationService>().getLocation();
    var list = <Map<String, dynamic>>[];
    final reason = getReason(reasonCode);
    final body = {
      'reason': reason,
      'time': DateTime.now().toIso8601String(),
      'long': location.longitude,
      'lat': location.latitude,
    };

    if (record != null) {
      list = List<Map<String, dynamic>>.from(jsonDecode(record).map((e) => Map<String, dynamic>.from(e))).toList();
      list.add(body);
      await StorageService().write(disconnectTimeKey, DateTime.now().toIso8601String());

      return list;
    } else {
      list.add(body);
      await StorageService().write(disconnectTimeKey, jsonEncode(list));
      return list;
    }
  }
}
