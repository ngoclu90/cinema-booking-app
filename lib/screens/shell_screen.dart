import 'package:flutter/material.dart';
import '../layouts/app_shell/index.dart';
import '../models/movie.dart';
import '../state/app_controller.dart';
import 'home_screen.dart';
import 'movie_screen.dart';
import 'profile_screen.dart';
import 'ticket_screen.dart';
import 'movie_detail_screen.dart';
import 'newspaper_screen.dart';

/*
 * Lớp ShellScreen:
 * Quản lý thanh điều hướng dưới và duy trì trạng thái các tab.
 * Sử dụng AnimatedSwitcher để tạo hiệu ứng chuyển tab đẹp mắt (Fade hoặc Zoom) mà không bị mất State.
 */
class ShellScreen extends StatefulWidget {
  final AppController controller;

  const ShellScreen({super.key, required this.controller});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  // Chuyển _pages thành dạng hàm (hoặc getter) để luôn lấy được themeMode mới nhất từ controller
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
    const NewspaperScreen(key: PageStorageKey<String>('voucher-tab')),
    const TicketScreen(key: PageStorageKey<String>('ticket-tab')),
    ProfileScreen(
      key: const PageStorageKey<String>('profile-tab'),
      controller: widget.controller,
      // Lấy themeMode trực tiếp từ controller
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
    // BỌC LISTENABLE BUILDER Ở ĐÂY:
    // Giúp AppShell và các Tab bên trong tự động cập nhật UI khi bồ đổi Theme Sáng/Tối
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return AppShell(
          selectedIndex: _selectedIndex,
          onTabSelected: _selectTab,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeInCubic,
            switchOutCurve: Curves.easeOutCubic,

            // --- [HIỆU ỨNG 1]: FADE & ZOOM (Thu phóng và Mờ dần nghệ thuật) ---
            transitionBuilder: (Widget child, Animation<double> animation) {
              final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              );
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              );
            },

            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ),
        );
      },
    );
  }
}