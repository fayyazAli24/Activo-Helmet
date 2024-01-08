import 'package:unilever_activo/domain/services/services.dart';

import '../api.dart';

class DateService{
   Future<String?>? getDate() async{
    try{
      String? response = await ApiServices().get(api: Api.alarmTime);
      if(response != null){
        print('the date from api is $response');
        return response;
      }else{
        return null;
      }
    }catch(e){

      return null;
    }
  }
}