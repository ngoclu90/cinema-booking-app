import '../../models/app_account.dart';
import '../../mocks/mock_data.dart';
import '../client/api_client.dart';
import '../payload/api_response.dart';

class AuthApi {
  final ApiClient _client;

  const AuthApi({ApiClient client = const ApiClient()}) : _client = client;

  Future<ApiResponse<AppAccount?>> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    final account = demoAccounts
        .where(
          (item) =>
              item.email.toLowerCase() == normalizedEmail &&
              item.password == normalizedPassword,
        )
        .cast<AppAccount?>()
        .firstOrNull;
    return _client.resolve('Login resolved', account);
  }
}
