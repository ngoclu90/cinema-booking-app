import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/services/user_api.dart';
import '../core/api_client.dart'; // Import ApiClient
import '../data/services/auth_service.dart';
import '../models/app_account.dart';

class AppController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserApi _userApi = UserApi();

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

  // Tải thông tin người dùng thực từ API và cập nhật vào AppAccount
  Future<void> reloadAccount() async {
    try {
      final response = await _userApi.getCurrentUser();
      final profile = response.data;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', profile.id);

      _currentAccount = AppAccount(
        id: profile.id.toString(),
        email: profile.email,
        password: '',
        role: (profile.roleId == 1 || profile.roleId == 2)
            ? AppUserRole.staff
            : AppUserRole.customer,
        roleLabel: profile.position ?? profile.membership,
        roleTitle: profile.roleId == 1
            ? 'Quản trị viên'
            : (profile.roleId == 2 ? 'Quản lý hệ thống' : 'Thành viên Cinema'),
        leftStatLabel: 'Điểm',
        leftStatValue: '${profile.points}',
        rightStatLabel: 'Hạng',
        rightStatValue: profile.membership,
        profile: profile,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Reload Account Error: $e');
    }
  }

  Future<void> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token != null && token.isNotEmpty) {
        // ĐỒNG BỘ TOKEN VÀO RAM NGAY LẬP TỨC
        ApiClient.setToken(token);
        await reloadAccount();
      }
    } catch (e) {
      debugPrint('Check Auth Error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final tokens = await _authService.login(email, password);
      if (tokens != null) {
        final accessToken = tokens['accessToken'] ?? tokens['token'];
        // ĐỒNG BỘ TOKEN VÀO RAM NGAY SAU KHI ĐĂNG NHẬP
        ApiClient.setToken(accessToken);

        await reloadAccount();
        return true;
      }
    } catch (e) {
      debugPrint('Login failed: $e');
    }
    return false;
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');

    // XÓA TOKEN KHỎI RAM
    ApiClient.setToken(null);

    _currentAccount = null;
    notifyListeners();
  }
}
