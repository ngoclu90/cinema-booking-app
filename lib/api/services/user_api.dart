import '../../models/app_account.dart';
import '../../mocks/mock_data.dart';
import '../client/api_client.dart';
import '../payload/api_response.dart';

class UserApi {
  final ApiClient _client;

  const UserApi({ApiClient client = const ApiClient()}) : _client = client;

  Future<ApiResponse<List<AppAccount>>> getDemoAccounts() {
    return _client.resolve('Fetched demo accounts', demoAccounts);
  }
}
