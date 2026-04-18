import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'screens/app_root_screen.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class CinemaBookingApp extends StatefulWidget {
  const CinemaBookingApp({super.key});

  @override
  State<CinemaBookingApp> createState() => _CinemaBookingAppState();
}

class _CinemaBookingAppState extends State<CinemaBookingApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => MaterialApp(
          title: 'Cinema Booking',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _controller.themeMode,
          home: AppRootScreen(controller: _controller),
        ),
      ),
    );
  }
}
