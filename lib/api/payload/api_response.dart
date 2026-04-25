import 'pagination_meta.dart';

class ApiResponse<T> {
  final String message;
  final T data;
  final PaginationMeta? meta;

  const ApiResponse({required this.message, required this.data, this.meta});
}
