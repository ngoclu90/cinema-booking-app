import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../api/client/endpoints.dart';
import '../../api/payload/api_response.dart';
import '../../core/api_client.dart';
import '../../models/news_item.dart';

class NewsService {
  final ApiClient _apiClient = ApiClient();
  Future<ApiResponse<List<NewsItem>>?> getNews({
    int page = 1,
    int perPage = 3,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.publicPosts,
        queryParameters: {
          'page': page,
          'perPage': perPage,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        final List<dynamic> rawData = responseMap['data'] ?? [];

        final newsList = rawData.map((json) => NewsItem.fromJson(json)).toList();

        return ApiResponse<List<NewsItem>>(
          message: responseMap['message']?.toString() ?? 'Success',
          data: newsList,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get News API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }

  /// Lấy chi tiết một bài báo theo ID
  Future<ApiResponse<NewsItem>?> getNewsDetail(int id) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.publicPostDetail(id),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        // Backend trả về PageResponse chứa list, ta lấy phần tử đầu tiên
        final List<dynamic> rawData = responseMap['data'] ?? [];

        if (rawData.isNotEmpty) {
          return ApiResponse<NewsItem>(
            message: responseMap['message']?.toString() ?? 'Success',
            data: NewsItem.fromJson(rawData.first),
          );
        }
      }
    } on DioException catch (e) {
      debugPrint('Get News Detail API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }
}