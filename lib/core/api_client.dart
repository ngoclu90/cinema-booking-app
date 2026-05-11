import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:dio/dio.dart' show BaseOptions, Dio, DioException, QueuedInterceptorsWrapper;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Singleton Pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  static String? _authToken; 

  static String get host => kIsWeb ? 'localhost' : (Platform.isAndroid ? '10.0.2.2' : 'localhost');
  static String get baseUrl => 'http://$host:8080/api/';
  
  // Bổ sung imgBaseUrl để hiển thị ảnh từ Server
  static String get imgBaseUrl => 'http://$host:8080';

  static void setToken(String? token) {
    _authToken = token;
    debugPrint('--- [API CLIENT] RAM Token updated ---');
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          String? token = _authToken;
          
          if (token == null || token.isEmpty) {
            final prefs = await SharedPreferences.getInstance();
            token = prefs.getString('jwt_token');
            _authToken = token;
          }
          
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }
        } catch (e) {
          debugPrint('--- [INTERCEPTOR ERROR] $e ---');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        debugPrint('--- [API ERR] Status: ${e.response?.statusCode} | Path: ${e.requestOptions.path} ---');
        return handler.next(e);
      },
    ));
  }
}
