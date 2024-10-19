import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app_keys.dart';
import 'package:unilever_activo/domain/services/storage_services.dart';

class SwitchCubit extends Cubit<bool> {
  SwitchCubit() : super(false) {
    initialValue();
  }

  Future<bool> initialValue() async {
    bool savedValue = false;
    String? value = await StorageService().read(autoConnectKey);
    if (value != null) {
      if (value.contains('true')) {
        savedValue = true;
      } else {
        savedValue = false;
      }
      emit(savedValue);
    }
    return savedValue;
  }

  Future<void> updateValue(bool value) async {
    print("the value written in switch is $value");
    await StorageService().write(autoConnectKey, value.toString());
    emit(value);
  }
}
