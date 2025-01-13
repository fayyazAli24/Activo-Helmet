import 'package:unilever_activo/domain/api.dart';
import 'package:unilever_activo/domain/services/services.dart';

class SignupServce {
  Future<dynamic> signup({String? name, String? email, String? password}) async {
    var bodySent = {'username': name, 'email': email, 'password': password};
    var response = await ApiServices().Register(api: Api.register, body: bodySent);

    if (response != null) {
      return response;
    }
    return null;
  }

  Future<dynamic> login({String? email, String? password}) async {
    try {
      var bodySent = {"email": email, "password": password};

      var response = await ApiServices().login(api: Api.login, body: bodySent);
      if (response != null) {
        print('cheeeeeck');
        return response;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
