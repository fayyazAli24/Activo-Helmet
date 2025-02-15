import 'dart:convert';

import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/services/services.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

import '../../app/app.dart';
import 'helmet_service.dart';

class UnSyncRecordService {
  // getting unsynced data from local storage and sending it to server
  Future<void> syncUnsyncedReasonRecord(bool shouldDelete) async {
    try {
      final reasonDataList = await StorageService().read(unSyncedReasonData);

      if (reasonDataList != null) {
        var list = List<Map<String, dynamic>>.from(jsonDecode(reasonDataList).map((e) => Map<String, dynamic>.from(e)))
            .toList();
        print('in next part');
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
      print("chhhhhhhhh $alertDataList");
      if (alertDataList != null) {
        var list = List<Map<String, dynamic>>.from(jsonDecode(alertDataList).map((e) => Map<String, dynamic>.from(e)))
            .toList();

        print('in next part2');
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
    print('the current data is $savedDate');
    if (savedDate != null) {

      final currentDate = DateTime.now();

      try {
        print('chal gaya bc $currentDate');
        await syncUnsyncedAlertRecord(true);
        await syncUnsyncedReasonRecord(true);

        await di.get<HelmetService>().syncUnsyncedData();

        await StorageService().delete(deviceListKey);
        await StorageService().delete(disconnectTimeKey);
        // }
        print('--------=====');
      } catch (e) {
        print('$e');
      }

      var list = await StorageService().read(deviceListKey);

      if (list != null) {
        List<dynamic> jsonList = jsonDecode(list);
        print('Decoded list here is of type: ${jsonList.runtimeType}');
        jsonList = jsonList.where((item) => item['synced'] == 0).toList();

        var updatedList = jsonEncode(jsonList);

        await StorageService().write(deviceListKey, updatedList);

        print('The updated list after writing is: $jsonList');

        await StorageService().write('date', DateTime.now().toIso8601String());
      }
    } else {
      await StorageService().write('date', DateTime.now().toIso8601String());
    }
  }
}
