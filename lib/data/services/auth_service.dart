import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // 1. LOGIN
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final apiResponse = response.data;
        final tokens = apiResponse['data']; 
        
        if (tokens != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', tokens['accessToken'] ?? '');
          await prefs.setString('refresh_token', tokens['refreshToken'] ?? '');
          return tokens;
        }
      }
    } on DioException catch (e) {
      print('Login API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }

  // 2. REGISTER - Send OTP
  Future<void> sendRegisterOtp(String email) async {
    await _apiClient.dio.post('/auth/register/send-otp', data: {
      'email': email,
    });
  }

  // 3. REGISTER - Verify & Create Account
  Future<void> verifyRegister({
    required String email,
    required String fullName,
    required String password,
    required String phone,
    required String otp,
  }) async {
    await _apiClient.dio.post('/auth/register/verify', data: {
      'email': email,
      'fullName': fullName,
      'password': password,
      'phone': phone,
      'otp': otp,
    });
  }

  // 4. FORGOT PASSWORD - Send OTP
  Future<void> sendForgotOtp(String email) async {
    await _apiClient.dio.post('/auth/forgot/send-otp', data: {
      'email': email,
    });
  }

  // 5. FORGOT PASSWORD - Verify & Reset
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _apiClient.dio.post('/auth/forgot/verify', data: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  // 6. REFRESH TOKEN
  Future<String?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rToken = prefs.getString('refresh_token');
      if (rToken == null) return null;

      final response = await _apiClient.dio.post('/auth/refresh', data: {
        'refreshToken': rToken,
      });

      if (response.statusCode == 200) {
        final newToken = response.data['data']['accessToken'];
        await prefs.setString('jwt_token', newToken);
        return newToken;
      }
    } catch (e) {
      print('Refresh Token Error: $e');
    }
    return null;
  }

  // 7. LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final rToken = prefs.getString('refresh_token');
    
    try {
      if (rToken != null) {
        await _apiClient.dio.post('/auth/logout', data: {
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
}
