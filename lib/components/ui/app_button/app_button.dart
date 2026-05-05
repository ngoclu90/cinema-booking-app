import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { md, lg }

class AppButton extends StatelessWidget {
  final String title;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final bool loading;
  final bool disabled;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.title,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.fullWidth = true,
    this.loading = false,
    this.disabled = false,
    this.leftIcon,
    this.rightIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading || onPressed == null;
    final height = size == AppButtonSize.lg ? 52.0 : 44.0;
    final colors = _resolveColors(isDisabled);

    return Semantics(
      button: true,
      label: title,
      enabled: !isDisabled,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: height,
        child: Material(
          color: colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(color: colors.border),
          ),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.foreground,
                        ),
                      ),
                    )
                  else if (leftIcon != null)
                    IconTheme(
                      data: IconThemeData(color: colors.foreground, size: 20),
                      child: leftIcon!,
                    ),
                  if (loading || leftIcon != null) const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  ),
                  if (rightIcon != null) const SizedBox(width: 8),
                  if (rightIcon != null)
                    IconTheme(
                      data: IconThemeData(color: colors.foreground, size: 20),
                      child: rightIcon!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _resolveColors(bool isDisabled) {
    if (isDisabled) {
      return const _ButtonColors(
        background: AppColors.bgSurface3,
        foreground: AppColors.textMuted,
        border: AppColors.borderDefault,
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return const _ButtonColors(
          background: AppColors.brandPrimary,
          foreground: AppColors.textPrimary,
          border: AppColors.brandPrimary,
        );
      case AppButtonVariant.secondary:
        return const _ButtonColors(
          background: AppColors.bgSurface2,
          foreground: AppColors.textPrimary,
          border: AppColors.borderDefault,
        );
      case AppButtonVariant.ghost:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.textPrimary,
          border: Colors.transparent,
        );
      case AppButtonVariant.danger:
        return const _ButtonColors(
          background: AppColors.stateError,
          foreground: AppColors.textPrimary,
          border: AppColors.stateError,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
