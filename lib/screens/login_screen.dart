import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../mocks/mock_data.dart';
import '../models/app_account.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';

class LoginScreen extends StatefulWidget {
  final AppController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // QUAN TRỌNG: Phải có await ở đây
      final success = await widget.controller.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (!success) {
        AppNotifier.warning(
          context,
          title: 'Đăng nhập chưa đúng',
          description: 'Vui lòng kiểm tra lại email hoặc mật khẩu.',
        );
      } else {
        AppNotifier.success(
          context,
          title: 'Đăng nhập thành công',
          description: 'Chào mừng bạn quay lại Cinema Booking.',
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.error(
          context,
          title: 'Lỗi kết nối',
          description: 'Không thể kết nối đến máy chủ Spring Boot.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginAsDemo(AppAccount account) {
    if (_isLoading) return;
    _emailController.text = account.email;
    _passwordController.text = account.password;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header UI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLayer(context, level: 1),
                  borderRadius: BorderRadius.circular(AppRadius.hero),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Image.asset(
                        'assets/images/logo_cinema_mark.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.movie,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cinema Booking',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Đăng nhập để vào ứng dụng.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Nhập email đăng nhập',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 18, right: 12),
                          child: FaIcon(FontAwesomeIcons.envelope, size: 16),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Vui lòng nhập email'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 18, right: 12),
                          child: FaIcon(FontAwesomeIcons.lock, size: 16),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Vui lòng nhập mật khẩu'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const FaIcon(
                                FontAwesomeIcons.arrowRightToBracket,
                                size: 14,
                              ),
                        label: Text(_isLoading ? 'Đang xử lý...' : 'Đăng nhập'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              Text(
                'Tài khoản dùng thử',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...demoAccounts.map(
                (account) => _DemoAccountCard(
                  account: account,
                  onLogin: () => _loginAsDemo(account),
                  isEnabled: !_isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoAccountCard extends StatelessWidget {
  final AppAccount account;
  final VoidCallback onLogin;
  final bool isEnabled;

  const _DemoAccountCard({
    required this.account,
    required this.onLogin,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLayer(context, level: 1),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              account.isStaff
                  ? Icons.badge_outlined
                  : Icons.person_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.roleLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  account.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isEnabled ? onLogin : null,
            child: const Text('Vào ngay'),
          ),
        ],
      ),
    );
  }
}
