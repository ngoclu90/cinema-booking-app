import 'package:dio/dio.dart' show BaseOptions, Dio, DioException, InterceptorsWrapper;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8080/api';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
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
    ));
  }

  Dio get dio => _dio;
}
