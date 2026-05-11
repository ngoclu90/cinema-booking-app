import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../client/endpoints.dart';
import '../payload/api_response.dart';

class AuthApi {
  // Luôn sử dụng instance Dio từ Singleton ApiClient duy nhất
  Dio get _dio => ApiClient().dio;

  // Gửi OTP đổi mật khẩu: POST /api/auth/password/send-otp
  Future<ApiResponse<void>> sendChangePasswordOtp() async {
    try {
      // Backend Java KHÔNG có @RequestBody nên không gửi kèm data
      final response = await _dio.post(ApiEndpoints.changePasswordSendOtp);
      
      return ApiResponse(
        message: response.data['message'] ?? 'Mã OTP đã được gửi tới email của bạn.',
        data: null,
      );
    } on DioException catch (e) {
      // Log lỗi chi tiết để debug
      print('--- [OTP ERROR] Status: ${e.response?.statusCode} | Data: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Phiên đăng nhập hết hạn hoặc không hợp lệ.';
      throw Exception(message);
    }
  }

  // Xác nhận OTP và đổi mật khẩu: POST /api/auth/password/verify
  Future<ApiResponse<void>> verifyChangePassword(String otp, String newPassword) async {
    try {
      // Khớp với @RequestBody Map<String, String> body trong Java
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
