import '../../mocks/mock_movies.dart';
import '../../models/movie.dart';
import '../client/api_client.dart';
import '../payload/api_response.dart';
import '../../mocks/mock_movies.dart';

/*
 * Lớp MovieApi:
 * Quản lý các nghiệp vụ truy xuất dữ liệu Phim.
 * Phân phối dữ liệu phim giả lập từ thực thể mock duy nhất thông qua hàm resolve của ApiClient,
 * đảm bảo giao diện hiển thị đồng bộ và sẵn sàng chuyển đổi cấu hình sang kết nối Database thật.
 */
class MovieApi {
  final ApiClient _client;

  MovieApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResponse<List<MoviePublicDto>>> getFeaturedMovies() async {
    return _client.resolve<List<MoviePublicDto>>(
      'Fetched featured movies',
      mockFeaturedMovies,
    );
  }

  Future<ApiResponse<List<MoviePublicDto>>> getNowPlayingMovies() async {
    return _client.resolve<List<MoviePublicDto>>(
      'Fetched now playing movies',
      mockNowPlayingMovies,
    );
  }

  Future<ApiResponse<List<MoviePublicDto>>> getComingSoonMovies() async {
    return _client.resolve<List<MoviePublicDto>>(
      'Fetched coming soon movies',
      mockComingSoonMovies,
    );
  }

  Future<ApiResponse<List<MoviePublicDto>>> getAllMovies() async {
    return _client.resolve<List<MoviePublicDto>>(
      'Fetched all movies',
      [mockSingleMovie],
    );
  }
}