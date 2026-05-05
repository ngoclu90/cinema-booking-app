import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class ApiClient {
  static late final Dio dio;
  static GoRouter? _router;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void init({
    required String baseUrl,
    GoRouter? router,
    GlobalKey<NavigatorState>? navigatorKey,
    Map<String, dynamic>? headers,
  }) {
    _router = router;
    _navigatorKey = navigatorKey;

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: headers ?? {},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onError: (err, handler) {
          final status = err.response?.statusCode;
          if (status == 401) {
            _handleUnauthorized();
          }
          handler.next(err);
        },
      ),
    );
  }

  static void _handleUnauthorized() {
    if (_router != null) {
      _router!.go('/login');
      return;
    }

    if (_navigatorKey?.currentState != null) {
      _navigatorKey!.currentState!.pushNamed('/login');
    }
  }

  static void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.post<T>(path, data: data, queryParameters: queryParameters);
  }
}
