import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:dio/dio.dart' show BaseOptions, Dio, DioException, QueuedInterceptorsWrapper, Headers;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  static String? _authToken; 

  static String get host => kIsWeb ? 'localhost' : (Platform.isAndroid ? '10.0.2.2' : 'localhost');
  static String get baseUrl => 'http://$host:8080/api/';
  static String get imgBaseUrl => 'http://$host:8080';

  static void setToken(String? token) {
    _authToken = token?.trim();
    debugPrint('--- [API CLIENT] RAM Token updated ---');
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        headers: {
          'Accept': 'application/json, text/plain, */*',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept-Language': 'vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7',
          'X-Requested-With': 'XMLHttpRequest',
          'Connection': 'keep-alive',
        },
      ),
    );

    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          String? token = _authToken;
          if (token == null || token.isEmpty) {
            final prefs = await SharedPreferences.getInstance();
            token = prefs.getString('jwt_token')?.trim();
            _authToken = token;
          }
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('--- [API CALL] ${options.method}: ${options.path}');
        } catch (e) {
          debugPrint('--- [INTERCEPTOR ERROR] $e ---');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        debugPrint('--- [API ERR] Status: ${e.response?.statusCode} | Path: ${e.requestOptions.path} ---');
        if (e.response?.data != null) {
          debugPrint('--- [SERVER DATA] ${e.response?.data} ---');
        }
        return handler.next(e);
      },
    ));
  }
}
