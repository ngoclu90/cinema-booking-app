import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../api/client/endpoints.dart';
import '../../api/payload/api_response.dart';
import '../../core/api_client.dart';
import '../../models/showtime_seat_map.dart';

class ShowtimeService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<ShowtimeSeatMap>?> getShowtimeSeatMap(
    String showtimeId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.showtimes}/$showtimeId/seats',
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          final responseMap = response.data as Map<String, dynamic>;
          final rawData = responseMap['data'] ?? responseMap;
          final seatMap = ShowtimeSeatMap.fromJson(
            rawData as Map<String, dynamic>,
          );
          return ApiResponse<ShowtimeSeatMap>(
            message: responseMap['message'] as String? ?? 'Success',
            data: seatMap,
          );
        }
      }
    } on DioException catch (e) {
      debugPrint(
        'Get Showtime Seat Map API Error: ${e.response?.data ?? e.message}',
      );
      rethrow;
    }

    return null;
  }
}
