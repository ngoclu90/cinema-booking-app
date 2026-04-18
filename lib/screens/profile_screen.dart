import 'package:flutter/material.dart';

import '../models/app_account.dart';
import '../theme/design_tokens.dart';
import '../utils/app_notifier.dart';
import '../widgets/accent_button.dart';
import '../widgets/profile_item.dart';

class ProfileScreen extends StatelessWidget {
  final AppAccount account;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.account,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final profile = account.profile;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(AppRadius.hero),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlphaPercent(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              profile.name.split(' ').first[0],
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                account.roleLabel,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                profile.email,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlphaPercent(0.70),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: profile.tierProgress,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileStat(
                            label: account.leftStatLabel,
                            value: account.leftStatValue,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _ProfileStat(
                            label: account.rightStatLabel,
                            value: account.rightStatValue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileItem(
                title: 'Thông tin tài khoản',
                subtitle: profile.membership,
                leadingIcon: account.isStaff
                    ? Icons.badge_outlined
                    : Icons.workspace_premium_outlined,
                badgeLabel: account.isStaff ? 'STAFF' : 'USER',
                onTap: () {
                  AppNotifier.info(
                    context,
                    title: 'Thông tin tài khoản',
                    description: account.roleTitle,
                  );
                },
              ),
              ProfileItem(
                title: 'Phương thức thanh toán',
                subtitle: 'Visa kết thúc bằng 1234',
                leadingIcon: Icons.credit_card_outlined,
                onTap: () {
                  AppNotifier.info(
                    context,
                    title: 'Phương thức thanh toán',
                    description: 'Thông tin thanh toán sẽ hiển thị tại đây.',
                  );
                },
              ),
              ProfileItem(
                title: 'Thể loại yêu thích',
                subtitle: profile.favoriteGenre,
                leadingIcon: Icons.movie_filter_outlined,
                onTap: () {
                  AppNotifier.success(
                    context,
                    title: 'Sở thích đã được lưu',
                    description: 'Thể loại yêu thích của bạn đã được cập nhật.',
                  );
                },
              ),
              ProfileItem(
                title: 'Giao diện ứng dụng',
                subtitle: _themeModeLabel(themeMode),
                leadingIcon: Icons.dark_mode_outlined,
                onTap: () => _showThemeModeSheet(context),
              ),
              ProfileItem(
                title: 'Hỗ trợ',
                subtitle: 'Trung tâm trợ giúp và câu hỏi thường gặp',
                leadingIcon: Icons.headset_mic_outlined,
                onTap: () {
                  AppNotifier.info(
                    context,
                    title: 'Hỗ trợ',
                    description: 'Bạn có thể xem các mục trợ giúp tại đây.',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AccentButton(
                label: 'Đăng xuất',
                reversed: true,
                onPressed: onLogout,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showThemeModeSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.hero),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeModeOption(
                  icon: Icons.brightness_auto_outlined,
                  title: 'Theo thiết bị',
                  subtitle: 'Tự đổi theo giao diện của máy',
                  selected: themeMode == ThemeMode.system,
                  onTap: () {
                    onThemeModeChanged(ThemeMode.system);
                    Navigator.of(sheetContext).pop();
                    AppNotifier.info(
                      context,
                      title: 'Đã đổi giao diện',
                      description: 'Ứng dụng sẽ tự theo thiết bị.',
                    );
                  },
                ),
                _ThemeModeOption(
                  icon: Icons.light_mode_outlined,
                  title: 'Sáng',
                  subtitle: 'Nền trắng tinh',
                  selected: themeMode == ThemeMode.light,
                  onTap: () {
                    onThemeModeChanged(ThemeMode.light);
                    Navigator.of(sheetContext).pop();
                    AppNotifier.info(
                      context,
                      title: 'Đã đổi giao diện',
                      description: 'Ứng dụng đang ở chế độ sáng.',
                    );
                  },
                ),
                _ThemeModeOption(
                  icon: Icons.dark_mode_outlined,
                  title: 'Tối',
                  subtitle: 'Nền đen thui',
                  selected: themeMode == ThemeMode.dark,
                  onTap: () {
                    onThemeModeChanged(ThemeMode.dark);
                    Navigator.of(sheetContext).pop();
                    AppNotifier.info(
                      context,
                      title: 'Đã đổi giao diện',
                      description: 'Ứng dụng đang ở chế độ tối.',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
        return 'Theo thiết bị';
    }
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlphaPercent(0.64),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlphaPercent(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlphaPercent(0.68),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
