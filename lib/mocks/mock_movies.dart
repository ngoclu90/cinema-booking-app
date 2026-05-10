import '../models/movie.dart';

/*
 * Tệp mock_movies.dart:
 * Định nghĩa duy nhất một thực thể phim mẫu khớp hoàn toàn với cấu trúc MoviePublicDto mới.
 * Dữ liệu này được tái sử dụng cho tất cả các danh sách (Featured, Now Playing, Coming Soon)
 * nhằm phục vụ việc dựng UI và chạy thử nghiệm luồng gọi API mà không gây phình to mã nguồn.
 */

final MoviePublicDto mockSingleMovie = MoviePublicDto(
  id: 101,
  title: 'Dune: Hành Tinh Cát - Phần Hai',
  shortDescription: 'Hành trình sử thi tiếp theo của Paul Atreides.',
  description: 'Paul Atreides hợp lực với Chani và người Fremen để tìm kiếm sự trả thù chống lại những kẻ âm mưu đã hủy hoại gia đình mình.',
  durationMinutes: 166,
  genre: 'ACTION, SCI-FI',
  language: 'Tiếng Anh (Phụ đề tiếng Việt)',
  format: 'IMAX 2D',
  director: 'Denis Villeneuve',
  cast: 'Timothée Chalamet, Zendaya, Rebecca Ferguson',
  posterUrl: 'assets/images/dune_part_two.jpg',
  bannerUrl: 'assets/images/dune_banner.jpg',
  trailerUrl: 'https://www.youtube.com/watch?v=Way9Dexny3w',
  ageRating: 'T16',
  releaseDate: DateTime(2026, 3, 1),
  status: 'NOW_SHOWING',
);

final List<MoviePublicDto> mockFeaturedMovies = [mockSingleMovie];
final List<MoviePublicDto> mockNowPlayingMovies = [mockSingleMovie];
final List<MoviePublicDto> mockComingSoonMovies = [mockSingleMovie];