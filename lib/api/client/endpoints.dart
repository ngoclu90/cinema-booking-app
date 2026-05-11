class ApiEndpoints {
  const ApiEndpoints._();

  // Auth Endpoints (Không để dấu / ở đầu để dùng với baseUrl có dấu / ở cuối)
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh';

  static const String registerSendOtp = 'auth/register/send-otp';
  static const String registerVerify = 'auth/register/verify';

  static const String forgotPasswordSendOtp = 'auth/forgot/send-otp';
  static const String forgotPasswordVerify = 'auth/forgot/verify';

  static const String changePasswordSendOtp = 'auth/password/send-otp';
  static const String changePasswordVerify = 'auth/password/verify';

  // User & Profile Endpoints
  static const String profile = 'users/me';
  static const String updateAvatar = 'users/me/avatar';
  static const String myBookings = 'users/me/bookings';
  static const String staffs = 'users/staffs';
  static const String customers = 'users/customers';

  // Business Endpoints
  static const String movies = 'movies';
  static const String cinemas = 'cinemas';
  static const String showtimes = 'showtimes';
  static const String bookings = 'bookings';
  static const String vouchers = 'vouchers';
  static const String news = 'news';
}
