import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/domain/services/location_service.dart';
import 'package:unilever_activo/main.dart';

registerServices() {
  di.registerSingleton<LocationService>(LocationService());
  di.registerSingleton<HelmetService>(HelmetService());
}
