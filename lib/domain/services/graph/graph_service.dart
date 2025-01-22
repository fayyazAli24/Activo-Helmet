import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/models/graph_mode.dart';
import 'package:unilever_activo/domain/services/http.dart';

class GraphService {
  Future<List<GraphDataModel>?> getData(String deviceId) async {
    print("%%%%%%%%5");

    var response = await APIService.get(api: Api.getGraph + deviceId);
    if (response != null) {
      print("doneeeeeeeeee");
      return graphDataModelFromJson(response);
    }
    return null;
  }
}
