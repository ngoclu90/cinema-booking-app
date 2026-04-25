import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';

class ShowtimeButton extends StatelessWidget {
  final String time;
  final bool selected;
  final bool disabled;
  final VoidCallback onPressed;

  const ShowtimeButton({
    super.key,
    required this.time,
    this.selected = false,
    this.disabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.brandPrimary : AppColors.bgSurface2;
    final foreground = disabled
        ? AppColors.textMuted
        : selected
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Semantics(
      button: true,
      label: 'Suất chiếu $time',
      enabled: !disabled,
      selected: selected,
      child: SizedBox(
        height: 44,
        child: Material(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: selected
                  ? AppColors.brandPrimary
                  : AppColors.borderDefault,
            ),
          ),
          child: InkWell(
            onTap: disabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(
                child: Text(
                  time,
                  style: AppTypography.bodyStrong.copyWith(color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
