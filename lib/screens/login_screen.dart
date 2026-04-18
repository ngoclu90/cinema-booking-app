import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final success = widget.controller.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!success) {
      AppNotifier.warning(
        context,
        title: 'Đăng nhập chưa đúng',
        description: 'Vui lòng kiểm tra lại email hoặc mật khẩu.',
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
          'Bạn đang vào với vai trò ${account.roleLabel.toLowerCase()}.',
    );
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
                            'Đăng nhập để vào ứng dụng với tài khoản nhân viên hoặc người dùng.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlphaPercent(0.72),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Nhập email đăng nhập',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 18, right: 12),
                          child: FaIcon(FontAwesomeIcons.envelope, size: 16),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 18, right: 12),
                          child: FaIcon(FontAwesomeIcons.lock, size: 16),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const FaIcon(
                          FontAwesomeIcons.arrowRightToBracket,
                          size: 14,
                        ),
                        label: const Text('Đăng nhập'),
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

  const _DemoAccountCard({required this.account, required this.onLogin});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlphaPercent(0.12),
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
                    const SizedBox(height: 2),
                    Text(
                      account.roleTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlphaPercent(0.68),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onLogin, child: const Text('Vào ngay')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Email: ${account.email}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Mật khẩu: ${account.password}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
