import 'dart:convert';

import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class UnSyncRecordService {
  // getting unsynced data from local storage and sending it to server
  Future<void> syncUnsyncedReasonRecord(bool shouldDelete) async {
    try {
      final reasonDataList = await StorageService().read(unSyncedReasonData);
      if (reasonDataList != null) {
        var list = List<Map<String, dynamic>>.from(jsonDecode(reasonDataList).map((e) => Map<String, dynamic>.from(e)))
            .toList();
        print("in next part");
        print(jsonEncode(list.first));
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

        print("in next part2");
        print(jsonEncode(list.first));
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
    print("the current data is $savedDate");
    if (savedDate != null) {
      final parsedDate = DateTime.parse(savedDate);
      print("the parssed data is $parsedDate");
      final currentDate = DateTime.now();
      print("the current data is $currentDate");

      if (parsedDate.day != currentDate.day) {
        try {
          print("chal gaya bc $currentDate");
          if (parsedDate.hour <= currentDate.hour && parsedDate.minute <= currentDate.minute) {
            await syncUnsyncedAlertRecord(true);
            await syncUnsyncedReasonRecord(true);
            print("--------=====");
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
