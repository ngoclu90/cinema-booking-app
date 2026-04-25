import '../../models/news_item.dart';
import '../../models/voucher.dart';
import '../../mocks/mock_data.dart';
import '../client/api_client.dart';
import '../payload/api_response.dart';

class VoucherApi {
  final ApiClient _client;

  const VoucherApi({ApiClient client = const ApiClient()}) : _client = client;

  Future<ApiResponse<List<Voucher>>> getVouchers() {
    return _client.resolve('Fetched vouchers', vouchers);
  }

  Future<ApiResponse<List<NewsItem>>> getNews() {
    return _client.resolve('Fetched news', newsItems);
  }
}
