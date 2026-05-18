import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../core/api_client.dart';
import '../../api/client/endpoints.dart';
import '../../models/seat.dart';

class SeatService {
  final ApiClient _apiClient = ApiClient();

  // API lấy danh sách ghế theo suất chiếu
  Future<ShowtimeSeatResponse?> getSeatMap(int showtimeId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.showtimes}/$showtimeId/seats',
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          final responseMap = response.data as Map<String, dynamic>;
          final rawData = responseMap['data'] ?? responseMap;
          return ShowtimeSeatResponse.fromJson(rawData as Map<String, dynamic>);
        }
      }
    } on DioException catch (e) {
      debugPrint('Get Seat Map API Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Parse Error: $e');
    }

    return null;
  }
}