import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../core/api_client.dart';
import '../../api/client/endpoints.dart';
import '../../models/ticket.dart';

class TicketService {
  final ApiClient _apiClient = ApiClient();
  Future<List<Ticket>?> getMyTickets() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.myBookings);

      if (response.statusCode == 200) {
        if (response.data is Map) {
          final responseMap = response.data as Map<String, dynamic>;
          final rawData = responseMap['data'] ?? responseMap;

          if (rawData is List) {
            return rawData.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
          }
        } else if (response.data is List) {
          return (response.data as List).map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } on DioException catch (e) {
      debugPrint('Get My Tickets API Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Parse Ticket Error: $e');
    }

    return null;
  }
}