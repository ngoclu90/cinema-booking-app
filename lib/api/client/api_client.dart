import '../payload/api_response.dart';

class ApiClient {
  final Duration mockLatency;

  const ApiClient({this.mockLatency = const Duration(milliseconds: 220)});

  Future<ApiResponse<T>> resolve<T>(String message, T data) async {
    await Future<void>.delayed(mockLatency);
    return ApiResponse<T>(message: message, data: data);
  }
}
