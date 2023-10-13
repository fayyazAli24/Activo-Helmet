import 'dart:convert';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<void> write(String key, BluetoothDevice value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, jsonEncode(value.toMap()));
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.get(key);

    final device = BluetoothDevice.fromMap(json.decode(value.toString()));

    return device;
  }

  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }
}
