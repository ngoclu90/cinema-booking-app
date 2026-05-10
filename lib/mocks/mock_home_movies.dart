import '../models/movie_card.dart'; // Import đúng file chứa model MovieCardDto thực tế của bạn

/*
 * Hàm getMockHomeMovies:
 * Cung cấp danh sách phim giả lập chuẩn MovieCardDto khớp 100% với DTO từ Backend.
 * Phục vụ hiển thị mượt mà trên HomeScreen mà không gây lỗi lệch kiểu dữ liệu.
 */
List<MovieCardDto> getMockHomeMovies() {
  return [
    MovieCardDto(
      id: 1,
      title: 'Dune: Hành Trình Cát - Phần Hai',
      durationMinutes: 166,
      genre: 'SCI_FI',
      posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=1025&auto=format&fit=cover',
      status: 'NOW_SHOWING',
      releaseDate: DateTime(2026, 3, 15),
    ),
    MovieCardDto(
      id: 2,
      title: 'Đại Tiệc Trăng Máu 8',
      durationMinutes: 90,
      genre: 'COMEDY',
      posterUrl: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?q=80&w=1170&auto=format&fit=cover',
      status: 'NOW_SHOWING',
      releaseDate: DateTime(2026, 4, 1),
    ),
    MovieCardDto(
      id: 3,
      title: 'Michael: Huyền Thoại Pop',
      durationMinutes: 150,
      genre: 'BIOGRAPHY',
      posterUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?q=80&w=1169&auto=format&fit=cover',
      status: 'COMING_SOON',
      releaseDate: DateTime(2026, 6, 20),
    ),
    MovieCardDto(
      id: 4,
      title: 'Kẻ Trộm Mặt Trăng 5',
      durationMinutes: 95,
      genre: 'ANIMATION',
      posterUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=1074&auto=format&fit=cover',
      status: 'COMING_SOON',
      releaseDate: DateTime(2026, 7, 5),
    ),
  ];
}