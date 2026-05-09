import '../../models/movie.dart';
import '../../mocks/mock_data.dart';
import '../client/api_client.dart';
import '../payload/api_response.dart';

class MovieApi {
  final ApiClient _client;

  const MovieApi({ApiClient client = const ApiClient()}) : _client = client;

  Future<ApiResponse<List<MoviePublicDto>>> getFeaturedMovies() {
    return _client.resolve('Fetched featured movies', featuredMovies);
  }

  Future<ApiResponse<List<MoviePublicDto>>> getNowPlayingMovies() {
    return _client.resolve('Fetched now playing movies', nowPlayingMovies);
  }

  Future<ApiResponse<List<MoviePublicDto>>> getComingSoonMovies() {
    return _client.resolve('Fetched coming soon movies', comingSoonMovies);
  }

  Future<ApiResponse<List<MoviePublicDto>>> getAllMovies() {
    return _client.resolve('Fetched all movies', allMovies);
  }
}
