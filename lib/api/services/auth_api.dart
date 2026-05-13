import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../client/endpoints.dart';
import '../payload/api_response.dart';

class AuthApi {
  Dio get _dio => ApiClient().dio;

  // Gửi OTP đổi mật khẩu: POST /api/auth/password/send-otp
  Future<ApiResponse<void>> sendChangePasswordOtp() async {
    try {
      // Gửi data: {} và ép kiểu Content-Type chuẩn xác
      final response = await _dio.post(
        ApiEndpoints.changePasswordSendOtp,
        data: {}, 
        options: Options(
          contentType: 'application/json; charset=utf-8',
        ),
      );
      
      return ApiResponse(
        message: response.data['message'] ?? 'Mã OTP đã được gửi tới email của bạn.',
        data: null,
      );
    } on DioException catch (e) {
      print('--- [OTP ERROR] Status: ${e.response?.statusCode} | Data: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Lỗi hệ thống khi gửi OTP.';
      throw Exception(message);
    }
  }

  // Xác nhận OTP và đổi mật khẩu
  Future<ApiResponse<void>> verifyChangePassword(String otp, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.changePasswordVerify,
        data: {
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return ApiResponse(
        message: response.data['message'] ?? 'Đổi mật khẩu thành công.',
        data: null,
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Xác thực OTP thất bại.';
      throw Exception(message);
    }
  }
}
