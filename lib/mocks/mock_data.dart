import '../models/app_account.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/news_item.dart';
import '../models/profile.dart';
import '../models/ticket.dart';
import '../models/voucher.dart';

// --- PHIM ---
List<MoviePublicDto> featuredMovies = [];
List<MoviePublicDto> nowPlayingMovies = [];
List<MoviePublicDto> comingSoonMovies = [];
List<MoviePublicDto> allMovies = [];

// --- HỆ THỐNG RẠP ---
List<Cinema> cinemas = [];

// --- NGƯỜI DÙNG ---
AppAccount? currentAccount;
ProfileUser? currentProfile;

// --- GIAO DỊCH & ƯU ĐÃI ---
List<Ticket> tickets = [];
List<Voucher> vouchers = [];
List<NewsItem> newsItems = [];

// --- CHỈ SỐ TRANG CHỦ ---
const List<Map<String, String>> homeMetrics = [
  {'value': '0', 'label': 'Rạp hoạt động'},
  {'value': '0', 'label': 'Suất chiếu'},
  {'value': '4DX', 'label': 'Trải nghiệm'},
];

/// Quản lý trạng thái dữ liệu tập trung
class DataState {
  // Cập nhật danh sách phim và tự động xử lý trùng lặp
  static void syncMovies({
    List<MoviePublicDto> featured = const [],
    List<MoviePublicDto> nowPlaying = const [],
    List<MoviePublicDto> comingSoon = const [],
  }) {
    featuredMovies = featured;
    nowPlayingMovies = nowPlaying;
    comingSoonMovies = comingSoon;

    final combined = [...featured, ...nowPlaying, ...comingSoon];
    final ids = <int>{};
    allMovies = combined.where((m) => ids.add(m.id)).toList();
  }

  // Khởi tạo thông tin người dùng sau khi đăng nhập
  static void setUser(AppAccount account) {
    currentAccount = account;
    currentProfile = account.profile;
  }

  // Xóa sạch trạng thái (Dùng khi đăng xuất)
  static void clear() {
    featuredMovies = [];
    nowPlayingMovies = [];
    comingSoonMovies = [];
    allMovies = [];
    cinemas = [];
    tickets = [];
    vouchers = [];
    currentAccount = null;
    currentProfile = null;
  }
}