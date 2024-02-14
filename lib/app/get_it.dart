import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/domain/services/dateServices.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/domain/services/unsynce_record_service.dart';

void registerServices() {
  di.registerSingleton<LocationService>(LocationService());
  di.registerSingleton<HelmetService>(HelmetService());
  di.registerSingleton<UnSyncRecordService>(UnSyncRecordService());
  di.registerLazySingleton<DateService>(() => DateService());
}
