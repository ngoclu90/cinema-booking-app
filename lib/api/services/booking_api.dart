import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/api_client.dart';
import '../../models/booking_create_response.dart';
import '../../models/hold_seat_response.dart';

class BookingApi {
  final ApiClient _client;

  BookingApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<HoldSeatResponse?> holdSeats({
    required int showtimeId,
    required List<int> seatIds,
  }) async {
    try {
      final response = await _client.dio.post(
        'booking/hold-seat',
        data: {'showtimeId': showtimeId, 'seatIds': seatIds},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return HoldSeatResponse.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      debugPrint('Hold Seat API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }

    return null;
  }

  Future<bool> calculateBooking({
    required int showtimeId,
    required List<int> seatIds,
    required List<Map<String, dynamic>> combos,
    required String voucherCode,
  }) async {
    try {
      final response = await _client.dio.post(
        'bookings/calculate',
        data: {
          'showtimeId': showtimeId,
          'seatIds': seatIds,
          'combos': combos,
          'voucherCode': voucherCode,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint(
        'Calculate Booking API Error: ${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<BookingCreateResponse?> createBooking({
    required int userId,
    required int showtimeId,
    required List<int> seatIds,
    required List<Map<String, dynamic>> combos,
    required List<Map<String, dynamic>> products,
    required String voucherCode,
    required String paymentMethod,
    required String bankCode,
  }) async {
    try {
      final response = await _client.dio.post(
        'bookings/create',
        data: {
          'userId': userId,
          'showtimeId': showtimeId,
          'seatIds': seatIds,
          'combos': combos,
          'products': products,
          'voucherCode': voucherCode,
          'paymentMethod': paymentMethod,
          'bankCode': bankCode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final payload = data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;
          return BookingCreateResponse.fromJson(payload);
        }
      }
    } on DioException catch (e) {
      debugPrint('Create Booking API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }

    return null;
  }

  Future<bool> releaseSeats({
    required String holdToken,
    int? showtimeId,
    List<int>? seatIds,
  }) async {
    try {
      final payload = <String, dynamic>{'holdToken': holdToken};
      if (showtimeId != null && showtimeId > 0) {
        payload['showtimeId'] = showtimeId;
      }
      if (seatIds != null && seatIds.isNotEmpty) {
        payload['seatIds'] = seatIds;
      }

      final response = await _client.dio.post(
        'booking/release-seat',
        data: payload,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Release Seat API Error: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}
