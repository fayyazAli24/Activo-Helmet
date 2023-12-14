import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/unsynce_record_service.dart';
import 'package:unilever_activo/main.dart';

void registerServices() {
  di.registerSingleton<LocationService>(LocationService());
  di.registerSingleton<HelmetService>(HelmetService());
  di.registerSingleton<UnSyncRecordService>(UnSyncRecordService());
}
