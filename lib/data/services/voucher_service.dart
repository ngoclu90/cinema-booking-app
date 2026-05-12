import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../api/client/endpoints.dart';
import '../../api/payload/api_response.dart';
import '../../core/api_client.dart';
import '../../models/voucher_check.dart';

class VoucherService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<VoucherCheckResult>?> checkVoucher({
    required String code,
    required int price,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.vouchers}/check',
        queryParameters: {'code': code, 'price': price},
      );

      if (response.statusCode == 200 && response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        final rawData = responseMap['data'] ?? responseMap;
        if (rawData is Map<String, dynamic>) {
          final result = VoucherCheckResult.fromJson(rawData);
          return ApiResponse<VoucherCheckResult>(
            message: responseMap['message']?.toString() ?? 'Success',
            data: result,
          );
        }
      }
    } on DioException catch (e) {
      debugPrint('Check Voucher API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }

    return null;
  }
}
