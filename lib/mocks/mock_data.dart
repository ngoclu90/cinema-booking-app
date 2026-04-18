import '../models/app_account.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/profile.dart';
import '../models/showtime.dart';
import '../models/ticket.dart';

/// Dữ liệu mẫu mô phỏng đúng cấu trúc phản hồi API.
/// Giao diện đang đọc từ các payload này để sau đó đổi sang API thật dễ hơn.

final Map<String, dynamic> customerProfileResponse = {
  'name': 'Luna Trần',
  'email': 'user@betatwo.vn',
  'membership': 'Thành viên Bạch kim',
  'phone': '+84 912 345 678',
  'points': 2480,
  'tierProgress': 0.74,
  'favoriteGenre': 'Hành động',
  'memberSince': '2022',
};

final Map<String, dynamic> staffProfileResponse = {
  'name': 'Minh Quân',
  'email': 'staff@betatwo.vn',
  'membership': 'Tổ vận hành Beta Two',
  'phone': '+84 988 221 100',
  'points': 1680,
  'tierProgress': 0.64,
  'favoriteGenre': 'Khoa học viễn tưởng',
  'memberSince': '2024',
};

final List<Map<String, dynamic>> demoShowtimeResponses = [
  {
    'id': 'show-1',
    'time': '10:10',
    'screen': 'Phòng 01',
    'price': '120k',
    'availability': 'Còn nhiều chỗ',
    'format': '2D',
    'language': 'Phụ đề',
    'dateLabel': 'Hôm nay',
  },
  {
    'id': 'show-2',
    'time': '13:40',
    'screen': 'Phòng 03',
    'price': '150k',
    'availability': 'Sắp hết chỗ',
    'format': 'IMAX',
    'language': 'Lồng tiếng',
    'dateLabel': 'Hôm nay',
  },
  {
    'id': 'show-3',
    'time': '18:20',
    'screen': 'Phòng 05',
    'price': '170k',
    'availability': 'Đặt nhanh',
    'format': '4DX',
    'language': 'Phụ đề',
    'dateLabel': 'Ngày mai',
  },
  {
    'id': 'show-4',
    'time': '20:45',
    'screen': 'Phòng 02',
    'price': '190k',
    'availability': 'Giờ vàng',
    'format': 'Premium',
    'language': 'Phụ đề',
    'dateLabel': 'Ngày mai',
  },
];

final List<Map<String, dynamic>> featuredMovieResponses = [
  {
    'id': 'bao-dem-thanh-pho',
    'title': 'Bão Đêm Thành Phố',
    'headline': 'Cuộc rượt đuổi dưới ánh đèn neon của Sài Gòn',
    'genre': 'Hành động · Giật gân',
    'duration': '2h 08m',
    'rating': 8.9,
    'detailLabel': 'Nổi bật',
    'description':
        'Một bom tấn nhịp độ cao nói về lòng trung thành, những phi vụ táo bạo và một thành phố không bao giờ ngủ.',
    'director': 'Nguyễn Long',
    'language': 'Tiếng Việt · Phụ đề EN',
    'releaseDate': '18.04.2026',
    'bookingHint': 'Suất tối đang được đặt nhanh tại Beta Two.',
    'accentValue': 0xFFE12636,
    'tags': ['Nổi bật', 'IMAX', '4DX'],
    'formats': ['2D', 'IMAX', '4DX'],
    'status': 'Đang chiếu',
    'showtimes': demoShowtimeResponses,
  },
  {
    'id': 'hanh-tinh-mua-dong',
    'title': 'Hành Tinh Mùa Đông',
    'headline': 'Khi hy vọng cuối cùng nằm ở phía bên kia dải ngân hà',
    'genre': 'Khoa học viễn tưởng · Phiêu lưu',
    'duration': '2h 16m',
    'rating': 8.6,
    'detailLabel': 'Đề cử',
    'description':
        'Một chuyến du hành liên hành tinh được kể bằng khung hình lớn, nhạc nền dày và những phi hành gia không còn đường quay lại.',
    'director': 'Trần Gia Hân',
    'language': 'Tiếng Anh · Phụ đề VI',
    'releaseDate': '21.04.2026',
    'bookingHint': 'Phù hợp với màn hình lớn và khu ghế đôi cao cấp.',
    'accentValue': 0xFF29435C,
    'tags': ['Không gian', 'Cao cấp'],
    'formats': ['2D', 'Premium'],
    'status': 'Đang chiếu',
    'showtimes': demoShowtimeResponses,
  },
];

final List<Map<String, dynamic>> nowPlayingMovieResponses = [
  ...featuredMovieResponses,
  {
    'id': 'qua-mat-trang',
    'title': 'Qua Mặt Trăng',
    'headline': 'Chuyện tình và sức hút giữa một hành trình vượt trời',
    'genre': 'Lãng mạn · Phiêu lưu',
    'duration': '1h 57m',
    'rating': 8.2,
    'detailLabel': 'Đề xuất',
    'description':
        'Tác phẩm cân bằng giữa cảm xúc, nhịp kể và những khung hình đẹp như poster treo rạp.',
    'director': 'Lê Minh Hà',
    'language': 'Tiếng Việt',
    'releaseDate': '15.04.2026',
    'bookingHint': 'Hợp với khán giả đi đôi và các khung giờ chiếu tối.',
    'accentValue': 0xFF1F5E58,
    'tags': ['Hẹn hò', '2D'],
    'formats': ['2D', 'Premium'],
    'status': 'Đang chiếu',
    'showtimes': demoShowtimeResponses,
  },
];

final List<Map<String, dynamic>> comingSoonMovieResponses = [
  {
    'id': 'mat-ma-bong-toi',
    'title': 'Mật Mã Bóng Tối',
    'headline': 'Bí ẩn mới được khóa bằng một vụ mất tích không dấu vết',
    'genre': 'Bí ẩn · Giật gân',
    'duration': '2h 04m',
    'rating': 9.0,
    'detailLabel': 'Sắp chiếu',
    'description':
        'Nhịp kể chậm, đẹp và gây nghiện, tập trung vào những mảnh ghép được mở dần qua từng cảnh quay.',
    'director': 'Phạm Khánh',
    'language': 'Tiếng Hàn · Phụ đề VI',
    'releaseDate': '03.05.2026',
    'bookingHint': 'Mở bán sớm tuần tới với suất chiếu đặc biệt.',
    'accentValue': 0xFF7A1834,
    'tags': ['Sắp chiếu', 'Cao cấp'],
    'formats': ['2D', 'Dolby Atmos'],
    'status': 'Sắp chiếu',
    'showtimes': demoShowtimeResponses,
  },
  {
    'id': 'ke-san-binh-minh',
    'title': 'Kẻ Săn Bình Minh',
    'headline': 'Cuộc săn đuổi mang màu sắc giả tưởng và nhịp ánh sáng dồn dập',
    'genre': 'Giả tưởng · Hành động',
    'duration': '2h 11m',
    'rating': 8.7,
    'detailLabel': 'Mở bán sớm',
    'description':
        'Một thương hiệu mới có nhiều đất diễn cho 4DX, hiệu ứng mạnh và những pha hành động khó quên.',
    'director': 'Đỗ Hoàng Sơn',
    'language': 'Tiếng Anh · Phụ đề VI',
    'releaseDate': '10.05.2026',
    'bookingHint':
        'Cảnh hành động lớn rất hợp với khán giả ưa trải nghiệm mạnh.',
    'accentValue': 0xFF8A471E,
    'tags': ['Giả tưởng', '4DX'],
    'formats': ['2D', '4DX'],
    'status': 'Sắp chiếu',
    'showtimes': demoShowtimeResponses,
  },
];

final List<Map<String, dynamic>> cinemaResponses = [
  {
    'id': 'beta-sai-gon-center',
    'name': 'Beta Two Sài Gòn Center',
    'address': '65 Lê Lợi, Quận 1, TP.HCM',
    'status': 'Đang mở cửa',
    'distance': '1.2 km',
    'halls': 8,
    'phone': '1900 0205',
    'landmark': 'Gần phố đi bộ Nguyễn Huệ',
    'operatingHours': '08:00 - 00:15',
    'accentValue': 0xFFE12636,
    'facilities': ['IMAX', '4DX', 'Ghế đôi'],
  },
  {
    'id': 'beta-east-hub',
    'name': 'Beta Two East Hub',
    'address': '12 Nguyễn Thị Minh Khai, Quận 3, TP.HCM',
    'status': 'Đang mở cửa',
    'distance': '2.3 km',
    'halls': 6,
    'phone': '1900 0306',
    'landmark': 'Bên cạnh công viên Lê Văn Tám',
    'operatingHours': '08:30 - 23:45',
    'accentValue': 0xFFAE1730,
    'facilities': ['Dolby Atmos', 'Ghế đôi', 'Quầy bắp nước'],
  },
  {
    'id': 'beta-riverside',
    'name': 'Beta Two Riverside',
    'address': '88 Trần Hưng Đạo, Quận 5, TP.HCM',
    'status': 'Sắp khai trương',
    'distance': '4.1 km',
    'halls': 5,
    'phone': '1900 0508',
    'landmark': 'Cách bến xe Chợ Lớn 5 phút',
    'operatingHours': '09:00 - 23:30',
    'accentValue': 0xFF6F0F1A,
    'facilities': ['Chiếu laser', 'Khu gia đình', 'Sảnh chờ'],
  },
];

final List<Map<String, dynamic>> ticketResponses = [
  {
    'id': 'ticket-1',
    'movieTitle': 'Bão Đêm Thành Phố',
    'cinemaName': 'Beta Two Sài Gòn Center',
    'screen': 'Phòng 01',
    'seat': 'B12 - B13',
    'date': 'Thứ Năm 24/04',
    'time': '20:45',
    'status': 'Đã xác nhận',
    'ticketCode': 'B2C-3821',
    'price': '360k',
    'snackCombo': 'Combo Medium x1',
    'hallType': 'IMAX',
    'gate': 'Cổng A',
    'qrHint': 'Mã QR sẽ hiển thị trước giờ chiếu',
  },
  {
    'id': 'ticket-2',
    'movieTitle': 'Hành Tinh Mùa Đông',
    'cinemaName': 'Beta Two East Hub',
    'screen': 'Phòng 03',
    'seat': 'C09',
    'date': 'Thứ Sáu 25/04',
    'time': '18:20',
    'status': 'Giữ chỗ',
    'ticketCode': 'B2C-7492',
    'price': '150k',
    'snackCombo': 'Không có combo',
    'hallType': 'Premium',
    'gate': 'Cổng C',
    'qrHint': 'Chờ xác nhận thanh toán để tạo mã check-in',
  },
];

const List<Map<String, String>> homeMetrics = [
  {'value': '12', 'label': 'Rạp hoạt động'},
  {'value': '48', 'label': 'Suất tối nay'},
  {'value': '4DX', 'label': 'Trải nghiệm'},
];

final ProfileUser demoProfile = ProfileUser.fromJson(customerProfileResponse);

final List<AppAccount> demoAccounts = List.unmodifiable([
  AppAccount(
    id: 'staff-account',
    email: 'staff@betatwo.vn',
    password: '123456',
    role: AppUserRole.staff,
    roleLabel: 'Nhân viên',
    roleTitle: 'Ca vận hành buổi tối',
    leftStatLabel: 'Mã nhân viên',
    leftStatValue: 'ST-028',
    rightStatLabel: 'Chi nhánh',
    rightStatValue: 'Quận 1',
    profile: ProfileUser.fromJson(staffProfileResponse),
  ),
  AppAccount(
    id: 'customer-account',
    email: 'user@betatwo.vn',
    password: '123456',
    role: AppUserRole.customer,
    roleLabel: 'Người dùng',
    roleTitle: 'Thành viên xem phim thân thiết',
    leftStatLabel: 'Điểm',
    leftStatValue: '2480',
    rightStatLabel: 'Thành viên từ',
    rightStatValue: '2022',
    profile: ProfileUser.fromJson(customerProfileResponse),
  ),
]);

final List<Showtime> demoShowtimes = List.unmodifiable(
  demoShowtimeResponses.map((showtime) => Showtime.fromJson(showtime)),
);

List<Movie> _buildMovies(List<Map<String, dynamic>> payload) {
  return List.unmodifiable(payload.map((movie) => Movie.fromJson(movie)));
}

List<Movie> _uniqueMovies(List<Movie> payload) {
  final seenIds = <String>{};
  return List.unmodifiable(payload.where((movie) => seenIds.add(movie.id)));
}

final List<Movie> featuredMovies = _buildMovies(featuredMovieResponses);
final List<Movie> nowPlayingMovies = _buildMovies(nowPlayingMovieResponses);
final List<Movie> comingSoonMovies = _buildMovies(comingSoonMovieResponses);
final List<Movie> allMovies = _uniqueMovies([
  ...featuredMovies,
  ...nowPlayingMovies,
  ...comingSoonMovies,
]);

final List<Cinema> cinemas = List.unmodifiable(
  cinemaResponses.map((cinema) => Cinema.fromJson(cinema)),
);

final List<Ticket> tickets = List.unmodifiable(
  ticketResponses.map((ticket) => Ticket.fromJson(ticket)),
);
