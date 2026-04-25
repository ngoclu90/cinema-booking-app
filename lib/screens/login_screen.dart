import 'package:flutter/material.dart';

import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../mocks/mock_data.dart';
import '../models/app_account.dart';
import '../state/app_controller.dart';
import '../utils/app_notifier.dart';

enum _AuthMode { login, register, forgot }

class LoginScreen extends StatefulWidget {
  final AppController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    setState(() => _loading = false);

    switch (_mode) {
      case _AuthMode.login:
        _login();
      case _AuthMode.register:
        AppNotifier.success(
          context,
          title: 'Đăng ký sẵn sàng',
          description: 'Form đăng ký đã đồng bộ UI và chờ nối API.',
        );
      case _AuthMode.forgot:
        AppNotifier.info(
          context,
          title: 'Đã gửi hướng dẫn',
          description:
              'Nếu email tồn tại, bạn sẽ nhận được hướng dẫn đặt lại mật khẩu.',
        );
    }
  }

  void _login() {
    final success = widget.controller.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!success) {
      AppNotifier.warning(
        context,
        title: 'Đăng nhập chưa đúng',
        description: 'Vui lòng kiểm tra email hoặc mật khẩu.',
      );
      return;
    }

    AppNotifier.success(
      context,
      title: 'Đăng nhập thành công',
      description: 'Chào mừng bạn quay lại Cinema Booking.',
    );
  }

  void _loginAsDemo(AppAccount account) {
    _emailController.text = account.email;
    _passwordController.text = account.password;
    widget.controller.loginAs(account);
    AppNotifier.success(
      context,
      title: 'Đăng nhập thành công',
      description:
          'Bạn đang dùng tài khoản ${account.roleLabel.toLowerCase()}.',
    );
  }

  void _setMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandPanel(mode: _mode),
                    const SizedBox(height: AppSpacing.xxl),
                    _ModeTabs(mode: _mode, onChanged: _setMode),
                    const SizedBox(height: AppSpacing.lg),
                    Form(
                      key: _formKey,
                      child: _AuthForm(
                        mode: _mode,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        nameController: _nameController,
                        hidePassword: _hidePassword,
                        onTogglePassword: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      title: _buttonLabel,
                      loading: _loading,
                      leftIcon: Icon(_buttonIcon),
                      onPressed: _submit,
                    ),
                    if (_mode == _AuthMode.login) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      const SectionHeader(
                        title: 'Tài khoản dùng thử',
                        subtitle: 'Dùng để kiểm tra flow customer hiện tại.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...demoAccounts.map(
                        (account) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _DemoAccountCard(
                            account: account,
                            onPressed: () => _loginAsDemo(account),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _buttonLabel {
    return switch (_mode) {
      _AuthMode.login => 'Đăng nhập',
      _AuthMode.register => 'Đăng ký',
      _AuthMode.forgot => 'Gửi hướng dẫn',
    };
  }

  IconData get _buttonIcon {
    return switch (_mode) {
      _AuthMode.login => Icons.login,
      _AuthMode.register => Icons.person_add_alt_1,
      _AuthMode.forgot => Icons.mark_email_read_outlined,
    };
  }
}

class _BrandPanel extends StatelessWidget {
  final _AuthMode mode;

  const _BrandPanel({required this.mode});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.bgApp,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Image.asset(
                  'assets/images/logo_cinema_mark.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cinema Booking',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    return switch (mode) {
      _AuthMode.login => 'Đăng nhập để đặt vé, lưu voucher và xem vé của bạn.',
      _AuthMode.register => 'Tạo tài khoản khách hàng để bắt đầu đặt vé.',
      _AuthMode.forgot => 'Khôi phục tài khoản bằng email đã đăng ký.',
    };
  }
}

class _ModeTabs extends StatelessWidget {
  final _AuthMode mode;
  final ValueChanged<_AuthMode> onChanged;

  const _ModeTabs({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModeButton(
          label: 'Đăng nhập',
          selected: mode == _AuthMode.login,
          onPressed: () => onChanged(_AuthMode.login),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ModeButton(
          label: 'Đăng ký',
          selected: mode == _AuthMode.register,
          onPressed: () => onChanged(_AuthMode.register),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ModeButton(
          label: 'Quên mật khẩu',
          selected: mode == _AuthMode.forgot,
          onPressed: () => onChanged(_AuthMode.forgot),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: selected
                ? AppColors.brandPrimary
                : AppColors.bgSurface2,
            side: BorderSide(
              color: selected
                  ? AppColors.brandPrimary
                  : AppColors.borderDefault,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionStrong.copyWith(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  final _AuthMode mode;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final bool hidePassword;
  final VoidCallback onTogglePassword;

  const _AuthForm({
    required this.mode,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.hidePassword,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (mode == _AuthMode.register) ...[
          AppInput(
            controller: nameController,
            placeholder: 'Họ và tên',
            leftIcon: const Icon(Icons.person_outline),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ tên';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppInput(
          controller: emailController,
          placeholder: 'Email',
          keyboardType: TextInputType.emailAddress,
          leftIcon: const Icon(Icons.mail_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!value.contains('@')) {
              return 'Email chưa hợp lệ';
            }
            return null;
          },
        ),
        if (mode != _AuthMode.forgot) ...[
          const SizedBox(height: AppSpacing.md),
          AppInput(
            controller: passwordController,
            placeholder: 'Mật khẩu',
            secureTextEntry: hidePassword,
            leftIcon: const Icon(Icons.lock_outline),
            rightIcon: IconButton(
              tooltip: hidePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
              onPressed: onTogglePassword,
              icon: Icon(
                hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.trim().length < 6) {
                return 'Mật khẩu tối thiểu 6 ký tự';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

class _DemoAccountCard extends StatelessWidget {
  final AppAccount account;
  final VoidCallback onPressed;

  const _DemoAccountCard({required this.account, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      pressable: true,
      onPressed: onPressed,
      padding: AppCardPadding.md,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandPrimarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.brandPrimary),
            ),
            child: Icon(
              account.isStaff ? Icons.badge_outlined : Icons.person_outline,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.roleLabel,
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  account.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
