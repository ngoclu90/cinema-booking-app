import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/services/auth_api.dart';
import '../core/api_client.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../state/app_controller.dart';
import '../utils/app_notifier.dart';

class ChangePasswordScreen extends StatefulWidget {
  final AppController controller; // Nhận controller để đồng bộ trạng thái

  const ChangePasswordScreen({super.key, required this.controller});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _otpController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _authApi = AuthApi();

  bool _otpSent = false;
  bool _isPending = false;
  int _resendSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ensureTokenSync();
  }

  // Đảm bảo Token được nạp vào RAM ngay khi mở màn hình để tránh lỗi 401
  Future<void> _ensureTokenSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null && token.isNotEmpty) {
        ApiClient.setToken(token);
        debugPrint('--- [CHANGE PASSWORD] Token synced to RAM ---');
      }
    } catch (e) {
      debugPrint('--- [CHANGE PASSWORD] Sync Error: $e ---');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _resendSeconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _handleSendOtp() async {
    // Kiểm tra trạng thái đăng nhập trước khi thực hiện
    if (!widget.controller.isLoggedIn) {
      AppNotifier.error(context, 
        title: 'Lỗi xác thực', 
        description: 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.'
      );
      return;
    }

    setState(() => _isPending = true);

    try {
      final response = await _authApi.sendChangePasswordOtp();

      if (mounted) {
        setState(() {
          _isPending = false;
          _otpSent = true;
        });
        _startTimer();
        AppNotifier.success(
          context,
          title: 'Đã gửi mã',
          description: response.message,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPending = false);
        AppNotifier.error(
          context,
          title: 'Thất bại',
          description: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  void _handleSubmit() async {
    final otp = _otpController.text.trim();
    final newPass = _passController.text;
    final confirmPass = _confirmPassController.text;

    if (otp.isEmpty) {
      AppNotifier.warning(context, title: 'Thiếu OTP', description: 'Vui lòng nhập mã OTP từ email.');
      return;
    }
    if (newPass.length < 6) {
      AppNotifier.warning(context, title: 'Mật khẩu yếu', description: 'Mật khẩu mới phải từ 6 ký tự.');
      return;
    }
    if (newPass != confirmPass) {
      AppNotifier.error(context, title: 'Lỗi', description: 'Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() => _isPending = true);

    try {
      final response = await _authApi.verifyChangePassword(otp, newPass);

      if (mounted) {
        AppNotifier.success(context, title: 'Thành công', description: response.message);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPending = false);
        AppNotifier.error(
          context,
          title: 'Lỗi',
          description: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgSurface2,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.brandPrimary, size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bảo mật tài khoản', style: AppTypography.captionStrong.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                          _otpSent ? 'Nhập mã xác nhận' : 'Xác thực qua Email',
                          style: AppTypography.title.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Nút gửi OTP với Countdown
            AppButton(
              title: _resendSeconds > 0
                  ? 'Gửi lại sau (${_resendSeconds}s)'
                  : (_otpSent ? 'Gửi lại mã OTP' : 'Gửi mã xác nhận đến Email'),
              variant: AppButtonVariant.secondary,
              loading: _isPending && !_otpSent,
              disabled: _resendSeconds > 0,
              leftIcon: const Icon(Icons.mark_email_read_outlined),
              onPressed: _handleSendOtp,
            ),

            if (_otpSent) ...[
              const SizedBox(height: AppSpacing.xxxl),
              const SectionHeader(title: 'Thiết lập mật khẩu mới'),
              const SizedBox(height: AppSpacing.md),

              _buildField(
                label: 'Mã xác nhận OTP',
                controller: _otpController,
                icon: Icons.password_rounded,
                hint: 'Nhập 6 số',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildField(
                label: 'Mật khẩu mới',
                controller: _passController,
                icon: Icons.lock_outline_rounded,
                hint: 'Ít nhất 6 ký tự',
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildField(
                label: 'Xác nhận mật khẩu',
                controller: _confirmPassController,
                icon: Icons.lock_reset_rounded,
                hint: 'Nhập lại mật khẩu mới',
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.huge),

              AppButton(
                title: 'Cập nhật mật khẩu',
                loading: _isPending && _otpSent,
                onPressed: _handleSubmit,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.captionStrong.copyWith(color: AppColors.textMuted, letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 22),
            filled: true,
            fillColor: AppColors.bgSurface2,
          ),
        ),
      ],
    );
  }
}
