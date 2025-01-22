import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:unilever_activo/domain/services/storage_services.dart';

import '../../app/app_keys.dart';

class APIService {
  StorageService storageServices = StorageService();

  static Future<dynamic> login({required String api, Map<String, dynamic>? body}) async {
    try {
      var header = {
        "Content-Type": "application/json",
      };
      log("*** Request ***");
      log("URI : $api");

      final response = await http.post(headers: header, Uri.parse(api), body: jsonEncode(body));

      if (response.statusCode == 200) {
        log("*** response ***");
        log("URI : $api");
        log("${response.body}");

        return response.body;
      }
      log("status code ${response.statusCode} || API : $api");
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  static Future<dynamic> get({required String api}) async {
    try {
      final token = await StorageService().read(tokenKey);
      var header;

      if (token != null) {
        header = {
          "Content-Type": "application/json",
          "MAPIkey": "Bearer $token",
        };
      }
      header = {
        "Content-Type": "application/json",
      };

      log("*** Request ***");
      log("URI : $api");

      final response = await http.get(Uri.parse(api));

      if (response.statusCode == 200) {
        log("*** response ***");
        log("URI : $api");

        log("${response.body}");

        return response.body;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<dynamic> post({required String api, String? id, Map<String, dynamic>? body}) async {
    try {
      final token = await StorageService().read(tokenKey);
      var header;

      if (token != null) {
        header = {
          "Content-Type": "application/json",
          "MAPIkey": token,
        };
      } else if (token == null) {
        header = {
          "Content-Type": "application/json",
        };
      }

      log("*** Request ***");
      log("URI : $api");
      log("$body");

      final response = await http.post(
        headers: header,
        Uri.parse(api),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        log("*** response ***");
        log("URI : $api");

        log("${response.body}");

        return response.body;
      }
      log("status code ${response.statusCode} || API : $api :: Response ${response.body}");
    } catch (e) {
      log("error : *** $e *** ");
    }
  }
}
