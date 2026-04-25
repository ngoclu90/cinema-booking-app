import 'package:flutter/material.dart';

import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/app_account.dart';
import '../utils/app_notifier.dart';

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
    return ScreenContainer(
      title: 'Hồ sơ',
      subtitle: 'Tài khoản và hỗ trợ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            padding: AppCardPadding.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.brandPrimary),
                      ),
                      child: Center(
                        child: Text(
                          profile.name.trim().isEmpty
                              ? 'U'
                              : profile.name.trim().characters.first,
                          style: AppTypography.title.copyWith(
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subtitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            profile.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppBadge(
                            label: account.roleLabel,
                            backgroundColor: AppColors.brandPrimarySoft,
                            foregroundColor: AppColors.textPrimary,
                            borderColor: AppColors.brandPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: account.leftStatLabel,
                        value: account.leftStatValue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _StatTile(
                        label: account.rightStatLabel,
                        value: account.rightStatValue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Tài khoản'),
          const SizedBox(height: AppSpacing.md),
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            subtitle: profile.phone,
            onPressed: () =>
                _notify(context, 'Thông tin cá nhân', profile.membership),
          ),
          _ProfileMenuItem(
            icon: Icons.event_seat_outlined,
            title: 'Vé của tôi',
            subtitle: 'Quản lý vé đã đặt',
            onPressed: () =>
                _notify(context, 'Vé của tôi', 'Mở từ thanh điều hướng dưới.'),
          ),
          _ProfileMenuItem(
            icon: Icons.confirmation_number_outlined,
            title: 'Voucher của tôi',
            subtitle: 'Ưu đãi và mã khuyến mãi',
            onPressed: () => _notify(
              context,
              'Voucher của tôi',
              'Voucher đang được đồng bộ.',
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật bảo mật tài khoản',
            onPressed: () => _notify(
              context,
              'Đổi mật khẩu',
              'Chức năng sẽ nối API xác thực.',
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Hỗ trợ'),
          const SizedBox(height: AppSpacing.md),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            subtitle: _themeLabel(themeMode),
            onPressed: () => _showThemeSheet(context),
          ),
          _ProfileMenuItem(
            icon: Icons.support_agent,
            title: 'Trung tâm hỗ trợ',
            subtitle: 'Câu hỏi thường gặp và liên hệ rạp',
            onPressed: () => _notify(
              context,
              'Hỗ trợ',
              'Beta Two luôn sẵn sàng hỗ trợ bạn.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            title: 'Đăng xuất',
            variant: AppButtonVariant.danger,
            leftIcon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }

  void _notify(BuildContext context, String title, String message) {
    AppNotifier.info(context, title: title, description: message);
  }

  Future<void> _showThemeSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeOption(
                  icon: Icons.dark_mode_outlined,
                  title: 'Tối',
                  subtitle: 'Giao diện cinematic mặc định',
                  selected: themeMode == ThemeMode.dark,
                  onPressed: () {
                    onThemeModeChanged(ThemeMode.dark);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _ThemeOption(
                  icon: Icons.brightness_auto_outlined,
                  title: 'Theo thiết bị',
                  subtitle: 'Vẫn giữ palette cinematic',
                  selected: themeMode == ThemeMode.system,
                  onPressed: () {
                    onThemeModeChanged(ThemeMode.system);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'Tối',
      ThemeMode.light => 'Tối',
      ThemeMode.system => 'Theo thiết bị',
    };
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.sm,
      backgroundColor: AppColors.bgSurface2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyStrong.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        pressable: true,
        onPressed: onPressed,
        padding: AppCardPadding.md,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSurface2,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onPressed;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        pressable: true,
        onPressed: onPressed,
        padding: AppCardPadding.md,
        child: Row(
          children: [
            Icon(icon, color: AppColors.brandPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_box, color: AppColors.brandPrimary),
          ],
        ),
      ),
    );
  }
}
