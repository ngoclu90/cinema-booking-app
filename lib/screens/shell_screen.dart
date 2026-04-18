import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../state/app_controller.dart';
import '../widgets/bottom_nav.dart';
import 'cinemas_screen.dart';
import 'home_screen.dart';
import 'movie_screen.dart';
import 'profile_screen.dart';
import 'ticket_screen.dart';
import 'movie_detail_screen.dart';

class ShellScreen extends StatefulWidget {
  final AppController controller;

  const ShellScreen({super.key, required this.controller});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(onMovieTap: _openMovieDetail),
    MovieScreen(onMovieTap: _openMovieDetail),
    TicketScreen(),
    CinemasScreen(),
    ProfileScreen(
      account: widget.controller.currentAccount!,
      themeMode: widget.controller.themeMode,
      onThemeModeChanged: widget.controller.setThemeMode,
      onLogout: widget.controller.logout,
    ),
  ];

  void _openMovieDetail(Movie movie, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: MovieDetailScreen(movie: movie, heroTag: heroTag),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          if (index == _selectedIndex) return;
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
