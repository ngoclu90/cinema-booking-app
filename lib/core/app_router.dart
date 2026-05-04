import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/app_root_screen.dart';
import '../state/app_controller.dart';

class AppRouter {
  final AppController controller;

  AppRouter(this.controller);

  late final router = GoRouter(
    initialLocation: '/',
    // Quan trọng: Lắng nghe sự thay đổi từ AppController để tự động chuyển trang
    refreshListenable: controller,
    redirect: (context, state) {
      final isLoggedIn = controller.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Nếu chưa đăng nhập và không ở trang login -> Bắt buộc về trang login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // 2. Nếu đã đăng nhập mà lại định vào trang login -> Đẩy vào trang chủ
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      // Không cần điều hướng lại
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(controller: controller),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => AppRootScreen(controller: controller),
      ),
    ],
  );
}
