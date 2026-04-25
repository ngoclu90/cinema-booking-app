import '../client/api_client.dart';
import '../payload/api_response.dart';

class BookingApi {
  final ApiClient _client;

  const BookingApi({ApiClient client = const ApiClient()}) : _client = client;

  Future<ApiResponse<bool>> holdSeats({
    required String showtimeId,
    required List<String> seats,
  }) {
    return _client.resolve('Held seats for $showtimeId', seats.isNotEmpty);
  }
}
