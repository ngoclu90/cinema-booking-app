import 'package:flutter/material.dart';

import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Các hoạt ảnh phân tầng (Staggered Animations) mượt mà, tiết kiệm tài nguyên
  late final Animation<double> _logoScale;
  late final Animation<double> _fade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    // Đặt thời gian chạy animation 1.5 giây nhẹ nhàng
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 1. Hoạt ảnh Logo & Nền: Zoom nhẹ từ 0.9 lên 1.0 (Không nảy) kết hợp hiện dần
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 2. Hoạt ảnh Chữ: Trượt nhẹ 1 khoảng rất nhỏ từ dưới lên cực kỳ tinh tế
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Hoạt ảnh thanh tiến trình phẳng chạy đều 100%
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp, // Sử dụng nền phẳng tiêu chuẩn hệ thống
      body: Stack(
        children: [
          /* NỘI DUNG CHÍNH (Căn giữa hoàn hảo) */
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /* Khung chứa Logo tối giản, chuẩn mực */
                  ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface2,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.borderDefault,
                          width: 1.0,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/logo_cinema_mark.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.movie_filter_rounded,
                          color: AppColors.brandPrimary,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  /* Tiêu đề & Slogan chuyển động êm ái */
                  SlideTransition(
                    position: _textSlide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CINEMA BOOKING',
                          textAlign: TextAlign.center,
                          style: AppTypography.title.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.8, // Giãn chữ nhẹ nhàng, sang trọng
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'ĐẶT VÉ NHANH • CHỌN GHẾ RÕ • VÀO RẠP GỌN',
                          textAlign: TextAlign.center,
                          style: AppTypography.captionStrong.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /* THANH TIẾN TRÌNH PHẲNG CHẠY Ở ĐÁY (Tinh tế, mỏng nhẹ) */
          Positioned(
            bottom: 60,
            left: 100,
            right: 100,
            child: FadeTransition(
              opacity: _fade,
              child: _buildProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  /*
   * Vẽ dải nạp tiến trình phẳng, tinh giản chuẩn chỉ
   */
  Widget _buildProgressIndicator() {
    return Container(
      height: 2, // Làm thanh mỏng hơn (2px) để tạo cảm giác tinh xảo
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.borderDefault.withOpacity(0.5),
        borderRadius: BorderRadius.circular(1.0),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return FractionallySizedBox(
              widthFactor: _progress.value,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary, // Màu thương hiệu phẳng
                  borderRadius: BorderRadius.circular(1.0),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}