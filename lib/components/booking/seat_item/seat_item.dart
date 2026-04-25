import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';

enum SeatStatus { available, selected, booked, vip, disabled }

class SeatItem extends StatelessWidget {
  final String code;
  final SeatStatus status;
  final VoidCallback? onPressed;

  const SeatItem({
    super.key,
    required this.code,
    required this.status,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _seatColors(status);
    final clickable =
        status != SeatStatus.booked && status != SeatStatus.disabled;

    return Semantics(
      button: clickable,
      label: 'Ghế $code',
      selected: status == SeatStatus.selected,
      enabled: clickable,
      child: Material(
        color: colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          side: BorderSide(color: colors.border),
        ),
        child: InkWell(
          onTap: clickable ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Center(
            child: Text(
              code.substring(1),
              style: AppTypography.captionStrong.copyWith(
                color: colors.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _SeatColors _seatColors(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return const _SeatColors(
          background: AppColors.seatAvailable,
          foreground: AppColors.textSecondary,
          border: AppColors.borderStrong,
        );
      case SeatStatus.selected:
        return const _SeatColors(
          background: AppColors.seatSelected,
          foreground: AppColors.textPrimary,
          border: AppColors.seatSelected,
        );
      case SeatStatus.booked:
        return const _SeatColors(
          background: AppColors.seatBooked,
          foreground: AppColors.textMuted,
          border: AppColors.borderDefault,
        );
      case SeatStatus.vip:
        return const _SeatColors(
          background: AppColors.seatVip,
          foreground: AppColors.textInverse,
          border: AppColors.seatVip,
        );
      case SeatStatus.disabled:
        return const _SeatColors(
          background: AppColors.seatDisabled,
          foreground: AppColors.textMuted,
          border: AppColors.borderDefault,
        );
    }
  }
}

class _SeatColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _SeatColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
