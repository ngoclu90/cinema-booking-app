import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/auth_service.dart';
import '../models/app_account.dart';
import '../models/profile.dart';

class AppController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  ThemeMode _themeMode = ThemeMode.system;
  AppAccount? _currentAccount;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  AppAccount? get currentAccount => _currentAccount;
  bool get isLoggedIn => _currentAccount != null;
  bool get isInitialized => _isInitialized;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  // Hàm tự động kiểm tra Token khi khởi động App
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      // Giả lập trạng thái đã đăng nhập nếu tìm thấy token
      _currentAccount = AppAccount(
        id: 'temp_id',
        email: 'user@example.com',
        password: '',
        role: AppUserRole.customer,
        roleLabel: 'Khách hàng',
        roleTitle: 'Thành viên Cinema',
        leftStatLabel: 'Vé đã đặt',
        leftStatValue: '0',
        rightStatLabel: 'Điểm tích lũy',
        rightStatValue: '0',
        profile: const ProfileUser(
          name: 'Người dùng',
          email: 'user@example.com',
          membership: 'Thành viên',
          phone: '',
          points: 0,
          tierProgress: 0.0,
          favoriteGenre: 'Hành động',
          memberSince: '2024',
        ),
      );
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final tokens = await _authService.login(email, password);

      if (tokens != null) {
        _currentAccount = AppAccount(
          id: 'temp_id',
          email: email,
          password: password,
          role: AppUserRole.customer,
          roleLabel: 'Khách hàng',
          roleTitle: 'Thành viên Cinema',
          leftStatLabel: 'Vé đã đặt',
          leftStatValue: '0',
          rightStatLabel: 'Điểm tích lũy',
          rightStatValue: '0',
          // KHÔNG dùng 'const' ở đây vì 'email' là biến truyền vào từ hàm
          profile: ProfileUser(
            name: 'Người dùng',
            email: email,
            membership: 'Thành viên',
            phone: '',
            points: 0,
            tierProgress: 0.0,
            favoriteGenre: 'Hành động',
            memberSince: '2024',
          ),
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login failed in AppController: $e');
    }
    return false;
  }

  void loginAs(AppAccount account) {
    _currentAccount = account;
    notifyListeners();
  }

  void logout() async {
    _currentAccount = null;
    await _authService.logout();
    notifyListeners();
  }
}