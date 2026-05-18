
import 'package:cinema_booking_app/api/client/endpoints.dart';
import 'package:cinema_booking_app/api/payload/api_response.dart';
import 'package:cinema_booking_app/models/post.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../core/api_client.dart';
class PostService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<Post>>?> getPosts(int page,int perPage) async{
    try {
      final response = await _apiClient.dio.get(
          '${ApiEndpoints.post}',
          queryParameters: {'page':page,'perPage':perPage});
      if(response.statusCode==200 && response.data is Map){
        final responseMap = response.data as Map<String, dynamic>;
        final rawData = responseMap['data'] ?? responseMap;

        final result = (rawData as List)
            .map((e) => Post.fromJson(e))
            .toList();
        return ApiResponse<List<Post>>(
          message: responseMap['message']?.toString() ?? 'Success',
          data: result,
        );
      }
    } on DioException catch(e){
      debugPrint('Check Voucher API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }
  Future<ApiResponse<Post>?> getPostsInfo(int id) async{
    try {
      final response = await _apiClient.dio.get(
          '${ApiEndpoints.post}/${id}');
      if(response.statusCode==200 && response.data is Map){
        final responseMap = response.data as Map<String, dynamic>;
        final rawData = responseMap['data'] ?? responseMap;

        final result = Post.fromJson(rawData);
        return ApiResponse<Post>(
          message: responseMap['message']?.toString() ?? 'Success',
          data: result,
        );
      }
    } on DioException catch(e){
      debugPrint('Check Voucher API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }
}