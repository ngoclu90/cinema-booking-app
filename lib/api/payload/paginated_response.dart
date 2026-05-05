import 'api_response.dart';
import 'pagination_meta.dart';

typedef PaginatedResponse<T> = ApiResponse<List<T>>;

PaginationMeta buildPaginationMeta({
  required int totalItems,
  int page = 1,
  int limit = 20,
}) {
  return PaginationMeta(
    page: page,
    limit: limit,
    totalItems: totalItems,
    totalPages: totalItems == 0 ? 0 : (totalItems / limit).ceil(),
  );
}
