import 'package:flutter/material.dart';

import '../mocks/mock_data.dart';
import '../models/app_account.dart';

class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppAccount? _currentAccount;

  ThemeMode get themeMode => _themeMode;
  AppAccount? get currentAccount => _currentAccount;
  bool get isLoggedIn => _currentAccount != null;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  bool login(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    for (final account in demoAccounts) {
      if (account.email.toLowerCase() == normalizedEmail &&
          account.password == normalizedPassword) {
        _currentAccount = account;
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  void loginAs(AppAccount account) {
    _currentAccount = account;
    notifyListeners();
  }

  void logout() {
    if (_currentAccount == null) return;
    _currentAccount = null;
    notifyListeners();
  }
}
