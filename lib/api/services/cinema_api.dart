import '../../models/cinema.dart';
import '../../mocks/mock_data.dart';
import '../client/api_client.dart';
import '../payload/api_response.dart';

class CinemaApi {
  final ApiClient _client;

  const CinemaApi({ApiClient client = const ApiClient()}) : _client = client;

  Future<ApiResponse<List<Cinema>>> getCinemas() {
    return _client.resolve('Fetched cinemas', cinemas);
  }
}
