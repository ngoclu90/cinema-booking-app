import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      final message =
          e.response?.data['message'] ?? 'Không thể lấy thông tin người dùng.';
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
        data: {'fullName': fullName, 'phone': phone},
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
  // Nhận XFile để hỗ trợ cả Web và Mobile
  Future<ApiResponse<String>> updateAvatar(XFile file) async {
    try {
      final String fileName = file.name;
      final String extension = fileName.split('.').last.toLowerCase();
      
      // Xác định mime-type cho ảnh
      final String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      MultipartFile multipartFile;
      
      if (kIsWeb) {
        // Trên Web: Sử dụng bytes thay vì filePath
        final bytes = await file.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
      } else {
        // Trên Mobile: Sử dụng fromFile
        multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );
      }

      final formData = FormData.fromMap({
        'avatar': multipartFile,
      });

      final response = await _apiClient.dio.post(
        ApiEndpoints.updateAvatar,
        data: formData,
      );

      return ApiResponse(
        message: response.data['message'] ?? 'Cập nhật ảnh đại diện thành công',
        data: response.data['data'],
      );
    } on DioException catch (e) {
      // Log lỗi chi tiết ra console để debug
      print('--- [UPLOAD ERROR] ---');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');

      final String message = e.response?.data['message'] ?? 'Lỗi kết nối máy chủ khi upload ảnh.';
      throw Exception(message);
    } catch (e) {
      print('--- [UNEXPECTED UPLOAD ERROR] --- $e');
      throw Exception('Lỗi xử lý file: $e');
    }
  }
}
