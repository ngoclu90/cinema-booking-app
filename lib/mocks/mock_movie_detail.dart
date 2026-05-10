import '../../models/movie.dart';

/*
 * Tệp mock_movie_detail.dart:
 * Cung cấp dữ liệu chi tiết giả lập chất lượng cao cho một bộ phim cụ thể.
 * Hỗ trợ kiểm thử hiển thị giao diện trước khi Spring Boot hoàn thiện cơ sở dữ liệu.
 */

final MoviePublicDto mockDetailedMovie = MoviePublicDto(
  id: 101,
  title: 'Dune: Hành Tinh Cát - Phần Hai',
  shortDescription: 'Hành trình sử thi vĩ đại chống lại hoàng đế.',
  description: 'Dune: Part Two sẽ khám phá hành trình thần thoại của Paul Atreides khi anh kết hợp với Chani và người Fremen trong khi tìm kiếm sự trả thù chống lại những kẻ âm mưu đã tiêu diệt gia đình mình. Đối mặt với sự lựa chọn giữa tình yêu của đời mình và số phận của vũ trụ được biết đến, Paul nỗ lực ngăn chặn một tương lai khủng khiếp mà chỉ anh mới có thể dự đoán trước.',
  durationMinutes: 166,
  genre: 'ACTION, SCI-FI, ADVENTURE',
  language: 'Tiếng Anh (Phụ đề tiếng Việt)',
  format: 'IMAX 2D, 4DX',
  director: 'Denis Villeneuve',
  cast: 'Timothée Chalamet, Zendaya, Rebecca Ferguson, Florence Pugh',
  posterUrl: 'assets/images/dune_part_two.jpg',
  bannerUrl: 'assets/images/dune_banner.jpg',
  trailerUrl: 'https://www.youtube.com/watch?v=Way9Dexny3w',
  ageRating: 'T16',
  releaseDate: DateTime(2026, 3, 1),
  status: 'NOW_SHOWING',
);