import '../../models/showtime.dart';
import '../../mocks/mock_data.dart';
import '../client/api_client.dart';
import '../payload/api_response.dart';

class ShowtimeApi {
  final ApiClient _client;

  const ShowtimeApi({ApiClient client = const ApiClient()}) : _client = client;
}
