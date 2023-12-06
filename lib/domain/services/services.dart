import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class AppService<T> {
  @protected
  Dio dio = Dio()
    ..interceptors.addAll(
      [
        InterceptorsWrapper(
          onRequest: (option, handler) async {
            //Timeout in 30 seconds
            // if (option.data is Map<String, dynamic>) {
            //   option.data = (option.data as Map<String, dynamic>)
            //     ..addAll({"version": Api.apiVersion});
            // }
            option.connectTimeout = const Duration(seconds: 30);

            return handler.next(option);
          },
        ),
        LogInterceptor(
          logPrint: (data) => print(
            '$data',
          ),
          request: true,
          responseHeader: false,
          requestHeader: false,
          responseBody: true,
          requestBody: true,
          error: true,
        ),
      ],
    );

  Future<dynamic> printin({required String api, Map<String, dynamic>? body}) async {}

  Future<dynamic> get({required String api, String? id, Map<String, dynamic>? body}) async {}

  Future<dynamic> post(
      {required String api, String? id, Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {}
}

class ApiServices extends AppService {
  @override
  Future printin({required String api, Object? body}) async {
    try {
      final response = await dio.post(
        api,
        data: body,
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } catch (e) {
      print('printin: $e');

      throw DioException(requestOptions: RequestOptions(data: body), message: '$e');
      // return e;
    }
  }

  @override
  Future get(
      {required String api, String? id, Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(api,
          data: body,
          queryParameters: queryParameters,
          options: Options(headers: {
            'Content-Type': 'application/json',
          }));

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } catch (e) {
      print(' $api: $e');
      throw DioException(
          requestOptions: RequestOptions(
            data: body,
            queryParameters: queryParameters,
          ),
          message: '$e');
    }
  }

  @override
  Future post({
    required String api,
    String? id,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(api,
          data: body,
          queryParameters: queryParameters,
          options: Options(headers: {
            'Content-Type': 'application/json',
          }));

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } catch (e) {
      print('$api: $e');
      throw DioException(
        requestOptions: RequestOptions(data: body),
        message: '$e',
        error: e,
      );
    }
  }
}
