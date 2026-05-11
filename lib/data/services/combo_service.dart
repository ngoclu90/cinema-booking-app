import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../api/payload/api_response.dart';
import '../../core/api_client.dart';
import '../../models/combo.dart';

class ComboService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<Combo>>?> getCombos({
    int page = 1,
    int perPage = 10,
    String filterType = 'Combo',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/public/combo',
        queryParameters: {
          'page': page,
          'perPage': perPage,
          'filterType': filterType,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        final rawList = responseMap['data'] as List<dynamic>? ?? const [];
        final combos = rawList
            .map((item) => Combo.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
        return ApiResponse<List<Combo>>(
          message: responseMap['message']?.toString() ?? 'Success',
          data: combos,
        );
      }
    } on DioException catch (e) {
      debugPrint('Get Combos API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }

    return null;
  }
}
