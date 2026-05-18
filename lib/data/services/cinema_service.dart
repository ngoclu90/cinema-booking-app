import 'package:cinema_booking_app/api/client/endpoints.dart';
import 'package:cinema_booking_app/api/payload/api_response.dart';
import 'package:cinema_booking_app/models/cinema.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../core/api_client.dart';
class CinemaService{
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<Cinema>?> getCinemas(int page,int perPage) async{
    try{
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.cinemas}/cinemas',
        queryParameters: {'page':page , 'perPage': perPage},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        final rawData = responseMap['data'] ?? responseMap;
        if (rawData is Map<String, dynamic>) {
          final result = Cinema.fromJson(rawData);
          return ApiResponse<Cinema>(
            message: responseMap['message']?.toString() ?? 'Success',
            data: result,
          );
        }
      }
    }on DioException catch(e){
      debugPrint('Check Cinema API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }
}