import 'dart:convert';

import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';
import 'package:unilever_activo/main.dart';

class UnSyncRecordService {
  Future<void> syncUnsyncedReasonRecord(bool shouldDelete) async {
    try {
      final reasonDataList = await StorageService().read(unSyncedReasonData);
      if (reasonDataList != null) {
        var list = List<Map<String, dynamic>>.from(jsonDecode(reasonDataList).map((e) => Map<String, dynamic>.from(e)))
            .toList();

        final res = await ApiServices().post(api: Api.disconnectReason, body: list);
        if (res != null) {
          if (shouldDelete) {
            await StorageService().delete(unSyncedReasonData);
          }
        }
      }
    } catch (e) {
      print('e $e');
    }
  }

  Future<void> syncUnsyncedAlertRecord(bool shouldDelete) async {
    try {
      final alertDataList = await StorageService().read(unSyncedAlertData);
      if (alertDataList != null) {
        var list = List<Map<String, dynamic>>.from(jsonDecode(alertDataList).map((e) => Map<String, dynamic>.from(e)))
            .toList();

        final res = await ApiServices().post(api: Api.disconnectingAlert, body: list);
        if (res != null) {
          if (shouldDelete) {
            await StorageService().delete(unSyncedAlertData);
          }
        }
      }
    } catch (e) {
      print('e $e');
    }
  }

  Future<void> clearPreviousRecords() async {
    final savedDate = await StorageService().read('date');
    if (savedDate != null) {
      final parsedDate = DateTime.parse(savedDate);
      final currentDate = DateTime.now();
      if (parsedDate.day != currentDate.day) {
        try {
          await syncUnsyncedAlertRecord(true);
          await syncUnsyncedReasonRecord(true);

          final list = await di.get<HelmetService>().syncUnsyncedData();
          if (list != null) {
            await StorageService().delete(deviceListKey);
            await StorageService().delete(lastDeviceKey);
          }
        } catch (e) {
          print('$e');
        }

        await StorageService().write('date', DateTime.now().toIso8601String());
      }
    } else {
      await StorageService().write('date', DateTime.now().toIso8601String());
    }
  }
}
