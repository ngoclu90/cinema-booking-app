import 'package:cinema_booking_app/models/voucher.dart';
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
  Future<ApiResponse<List<Voucher>>?> getVoucher({required int page,required int perPage}) async{
    try {
      final response = await _apiClient.dio.get(
          '${ApiEndpoints.vouchers}',
          queryParameters: {'page':page,'perPage':perPage});
      if(response.statusCode==200 && response.data is Map){
        final responseMap = response.data as Map<String, dynamic>;
        final rawData = responseMap['data'] ?? responseMap;
        debugPrint("DATA: ${rawData}");
          final result = (rawData as List)
              .map((e) => Voucher.fromJson2(e))
              .toList();
          return ApiResponse<List<Voucher>>(
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
  Future<ApiResponse<Voucher>?> getVoucherInfo({required int id}) async{
    try {
      final response = await _apiClient.dio.get(
          '${ApiEndpoints.vouchers}/${id}', queryParameters: {'id':id});

      if(response.statusCode==200 && response.data is Map){
        final responseMap = response.data as Map<String, dynamic>;
        final rawData = responseMap['data'] ?? responseMap;
        if (rawData is Map<String, dynamic>) {
          final result = Voucher.fromJson(rawData);
          return ApiResponse<Voucher>(
            message: responseMap['message']?.toString() ?? 'Success',
            data: result,
          );
        }
      }
    } on DioException catch(e){
      debugPrint('Check Voucher API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
    return null;
  }
}
