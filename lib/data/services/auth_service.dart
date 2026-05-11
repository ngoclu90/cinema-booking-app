import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../../api/client/endpoints.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // 1. LOGIN
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // Sử dụng ApiEndpoints thay vì text cứng có dấu /
      final response = await _apiClient.dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final apiResponse = response.data;
        final tokens = apiResponse['data']; 
        
        if (tokens != null) {
          final prefs = await SharedPreferences.getInstance();
          // Thử lấy token từ nhiều key có thể xảy ra từ Backend
          final String accessToken = tokens['accessToken'] ?? tokens['token'] ?? '';
          final String refreshToken = tokens['refreshToken'] ?? tokens['refresh_token'] ?? '';
          
          if (accessToken.isNotEmpty) {
            await prefs.setString('jwt_token', accessToken);
            await prefs.setString('refresh_token', refreshToken);
            print('--- Login Success: Token saved ---');
            return tokens;
          }
        }
      }
    } on DioException catch (e) {
      print('Login API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }

  // 2. LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final rToken = prefs.getString('refresh_token');
    
    try {
      if (rToken != null && rToken.isNotEmpty) {
        await _apiClient.dio.post(ApiEndpoints.logout, data: {
          'refreshToken': rToken,
        });
      }
    } catch (e) {
      print('Logout API Error: $e');
    } finally {
      await prefs.remove('jwt_token');
      await prefs.remove('refresh_token');
    }
  }

  // Thêm các phương thức khác sử dụng ApiEndpoints...
  Future<void> sendRegisterOtp(String email) async {
    await _apiClient.dio.post(ApiEndpoints.registerSendOtp, data: {'email': email});
  }
}
