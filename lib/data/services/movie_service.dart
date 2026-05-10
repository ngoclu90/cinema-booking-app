  import 'package:cinema_booking_app/api/client/endpoints.dart';
  import 'package:cinema_booking_app/api/payload/api_response.dart';
  import 'package:cinema_booking_app/models/movie.dart';
  import 'package:dio/dio.dart';
  import '../../core/api_client.dart';
import '../../models/showtime_item.dart';

  class MovieService {
    final ApiClient _apiClient = ApiClient();

    Future<ApiResponse<List<MoviePublicDto>>?> getAllMovie() async {
      try {
        final response = await _apiClient.dio.get('/${ApiEndpoints.movies}/movies');
        if (response.statusCode == 200) {
          final responseMap = response.data as Map<String, dynamic>;
          final rawList = responseMap['data'] as List<dynamic>? ?? [];
          final movies = rawList
              .map((item) => MoviePublicDto.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<MoviePublicDto>>(
            message: responseMap['message'] as String? ?? 'Success',
            data: movies,
          );
        }
      } on DioException catch (e) {
        print('Get Movies API Error: ${e.response?.data ?? e.message}');
        rethrow;
      }
      return null;
    }

    Future<ApiResponse<MoviePublicDto>?> getMovieDetail(int id) async {
      try {
        final response = await _apiClient.dio.get('/${ApiEndpoints.movies}/movie-detail/$id');
        if (response.statusCode == 200) {
          final responseMap = response.data as Map<String, dynamic>;
          final rawData = responseMap['data'] as Map<String, dynamic>?;

          if (rawData == null) return null;

          final movie = MoviePublicDto.fromJson(rawData);

          return ApiResponse<MoviePublicDto>(
            message: responseMap['message'] as String? ?? 'Success',
            data: movie,
          );
        }
      } on DioException catch (e) {
        print('Get Movie Detail API Error: ${e.response?.data ?? e.message}');
        rethrow;
      }
      return null;
    }

    Future<ApiResponse<List<MovieWithShowtimesDto>>?> getCinemasWithShowtimes(
        int movieId, {
          int? cinemaId,
        }) async {
      try {
        final Map<String, dynamic> queryParameters = {};
        if (cinemaId != null) {
          queryParameters['cinemaId'] = cinemaId;
        }

        final response = await _apiClient.dio.get(
          '/${ApiEndpoints.movies}/$movieId/cinemas-showtimes',
          queryParameters: queryParameters,
        );

        if (response.statusCode == 200) {
          final responseMap = response.data as Map<String, dynamic>;
          final rawList = responseMap['data'] as List<dynamic>? ?? [];
          final data = rawList
              .map((item) => MovieWithShowtimesDto.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<MovieWithShowtimesDto>>(
            message: responseMap['message'] as String? ?? 'Success',
            data: data,
          );
        }
      } on DioException catch (e) {
        print('Get Cinemas Showtimes API Error: ${e.response?.data ?? e.message}');
        rethrow;
      }
      return null;
    }
  }