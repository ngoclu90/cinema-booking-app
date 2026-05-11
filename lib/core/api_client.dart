import 'dart:io';

import 'package:dio/dio.dart'
    show BaseOptions, Dio, DioException, InterceptorsWrapper;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // em cấu hình để test trên máy thật của em thôi nhe
  static const bool device = true;
  static String get baseUrl => (device && !kIsWeb && Platform.isAndroid)
      ? 'http://192.168.123.7:8080/api'
      : (!kIsWeb && Platform.isAndroid
            ? 'http://10.0.2.2:8080/api'
            : 'http://localhost:8080/api');

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  ApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tự động lấy token từ bộ nhớ và đính kèm vào header
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Xử lý lỗi tập trung (ví dụ: logout nếu token hết hạn)
          if (e.response?.statusCode == 401) {
            // Xử lý logout tại đây
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
