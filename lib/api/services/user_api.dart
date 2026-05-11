import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../models/profile.dart';
import '../client/endpoints.dart';
import '../payload/api_response.dart';

class UserApi {
  final ApiClient _apiClient = ApiClient();

  // Lấy thông tin user hiện tại: GET /api/users/me
  Future<ApiResponse<ProfileUser>> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.profile);
      return ApiResponse(
        message: 'Thành công',
        data: ProfileUser.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Không thể lấy thông tin người dùng.';
      throw Exception(message);
    }
  }

  // Cập nhật thông tin cá nhân: PUT /api/users/me
  Future<ApiResponse<void>> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.profile,
        data: {
          'fullName': fullName,
          'phone': phone,
        },
      );
      return ApiResponse(
        message: response.data['message'] ?? 'Cập nhật thành công',
        data: null,
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Cập nhật thất bại.';
      throw Exception(message);
    }
  }

  // Cập nhật Avatar: POST /api/users/me/avatar
  Future<ApiResponse<String>> updateAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiEndpoints.updateAvatar,
        data: formData,
      );
      return ApiResponse(
        message: 'Cập nhật ảnh đại diện thành công',
        data: response.data['data'],
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Không thể tải ảnh lên.';
      throw Exception(message);
    }
  }
}
