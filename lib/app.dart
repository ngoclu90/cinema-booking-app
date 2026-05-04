import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'core/app_router.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class CinemaBookingApp extends StatefulWidget {
  const CinemaBookingApp({super.key});

  @override
  State<CinemaBookingApp> createState() => _CinemaBookingAppState();
}

class _CinemaBookingAppState extends State<CinemaBookingApp> {
  late final AppController _controller;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _appRouter = AppRouter(_controller);
    
    // Tự động kiểm tra trạng thái đăng nhập khi App khởi động
    _controller.checkAuth();
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
        builder: (context, _) {
          // Nếu App chưa kiểm tra xong Token, hiển thị màn hình chờ (Splash)
          if (!_controller.isInitialized) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp.router(
            title: 'Cinema Booking',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _controller.themeMode,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
