import '../models/app_account.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/news_item.dart';
import '../models/profile.dart';
import '../models/ticket.dart';
import '../models/voucher.dart';

/*
 * Danh sách tài khoản dùng thử (demoAccounts):
 * Cung cấp dữ liệu mẫu cho hai vai trò: Khách hàng (customer) và Nhân viên (staff).
 * Giúp chạy thử nghiệm các tính năng nghiệp vụ nội bộ khi chưa liên kết API thật.
 */
final List<AppAccount> demoAccounts = [
  AppAccount(
    id: '1',
    email: 'user@betatwo.vn',
    password: '123456',
    role: AppUserRole.customer,
    roleLabel: 'Người dùng',
    roleTitle: 'Thành viên',
    leftStatLabel: 'Điểm',
    leftStatValue: '1250',
    rightStatLabel: 'Thành viên từ',
    rightStatValue: '2025',
    profile: ProfileUser(
      name: 'Hậu Huỳnh',
      email: 'user@betatwo.vn',
      membership: 'Thành viên Bạc',
      phone: '0901234567',
      points: 1250,
      tierProgress: 0.65,
      favoriteGenre: 'Hành động',
      memberSince: '2025',
    ),
  ),
  AppAccount(
    id: '2',
    email: 'staff@betatwo.vn',
    password: '123456',
    role: AppUserRole.staff,
    roleLabel: 'Nhân viên',
    roleTitle: 'Quản trị viên',
    leftStatLabel: 'Ca trực',
    leftStatValue: 'Sáng',
    rightStatLabel: 'Mã nhân viên',
    rightStatValue: 'STAFF01',
    profile: ProfileUser(
      name: 'Đức PNJ',
      email: 'staff@betatwo.vn',
      membership: 'Quản trị viên',
      phone: '0907654321',
      points: 0,
      tierProgress: 1.0,
      favoriteGenre: 'Drama',
      memberSince: '2024',
    ),
  ),
];

/*
 * Trạng thái lưu trữ dữ liệu cục bộ:
 * Quản lý danh sách các thực thể trong hệ thống như Phim, Rạp, Tài khoản, Giao dịch và Ưu đãi.
 */
List<MoviePublicDto> featuredMovies = [];
List<MoviePublicDto> nowPlayingMovies = [];
List<MoviePublicDto> comingSoonMovies = [];
List<MoviePublicDto> allMovies = [];

List<Cinema> cinemas = [];

AppAccount? currentAccount;
ProfileUser? currentProfile;

List<Ticket> tickets = [];
List<Voucher> vouchers = [];
List<NewsItem> newsItems = [];

const List<Map<String, String>> homeMetrics = [
  {'value': '0', 'label': 'Rạp hoạt động'},
  {'value': '0', 'label': 'Suất chiếu'},
  {'value': '4DX', 'label': 'Trải nghiệm'},
];

/*
 * Lớp DataState:
 * Quản lý tập trung toàn bộ trạng thái và các thao tác đồng bộ hóa dữ liệu.
 * Cung cấp các phương thức tiện ích để cập nhật danh sách phim, lưu thông tin phiên đăng nhập
 * và xóa sạch bộ nhớ tạm khi người dùng thực hiện đăng xuất.
 */
class DataState {
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

  static void setUser(AppAccount account) {
    currentAccount = account;
    currentProfile = account.profile;
  }

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