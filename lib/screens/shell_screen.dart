import 'package:flutter/material.dart';
import '../layouts/app_shell/index.dart';
import '../models/movie.dart';
import '../state/app_controller.dart';
import 'home_screen.dart';
import 'movie_screen.dart';
import 'profile_screen.dart';
import 'ticket_screen.dart';
import 'movie_detail_screen.dart';
import 'voucher_screen.dart';

/*
 * Lớp ShellScreen:
 * Đóng vai trò là khung sườn (Shell Layout) chính của ứng dụng.
 * Quản lý thanh điều hướng dưới (Bottom Navigation Bar) và duy trì trạng thái
 * của các tab màn hình chính sử dụng IndexedStack để tránh việc tải lại trang khi chuyển tab.
 */
class ShellScreen extends StatefulWidget {
  final AppController controller;

  const ShellScreen({super.key, required this.controller});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

/*
 * Trạng thái của ShellScreen:
 * Quản lý việc chuyển đổi tab và truyền các hàm callback điều hướng giữa các màn hình con.
 * Thiết lập hiệu ứng chuyển cảnh mượt mà FadeTransition kết hợp Hero Animation khi mở màn hình chi tiết phim.
 */
class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(
      key: const PageStorageKey<String>('home-tab'),
      onMovieTap: _openMovieDetail,
      onBrowseRequested: () => _selectTab(1),
      onVoucherRequested: () => _selectTab(2),
      onTicketsRequested: () => _selectTab(3),
    ),
    MovieScreen(
      key: const PageStorageKey<String>('movie-tab'),
      onMovieTap: _openMovieDetail,
    ),
    const VoucherScreen(key: PageStorageKey<String>('voucher-tab')),
    const TicketScreen(key: PageStorageKey<String>('ticket-tab')),
    ProfileScreen(
      key: const PageStorageKey<String>('profile-tab'),
      account: widget.controller.currentAccount!,
      themeMode: widget.controller.themeMode,
      onThemeModeChanged: widget.controller.setThemeMode,
      onLogout: widget.controller.logout,
    ),
  ];

  void _selectTab(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openMovieDetail(MoviePublicDto movie, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: MovieDetailScreen(movie: movie, heroTag: heroTag),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedIndex,
      onTabSelected: _selectTab,
      child: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}