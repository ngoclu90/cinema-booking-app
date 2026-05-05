import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../../ui/index.dart';

class BookingFooter extends StatelessWidget {
  final List<String> selectedSeats;
  final String totalPrice;
  final String fallbackPrice;
  final VoidCallback onContinue;

  const BookingFooter({
    super.key,
    required this.selectedSeats,
    required this.totalPrice,
    required this.fallbackPrice,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedSeats.isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasSelection ? 'Ghế đã chọn' : 'Chưa chọn ghế',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hasSelection
                            ? selectedSeats.join(', ')
                            : 'Chọn ghế để tiếp tục',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hasSelection ? totalPrice : fallbackPrice,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                    Text(
                      hasSelection ? '${selectedSeats.length} ghế' : 'mỗi vé',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              title: 'Tiếp tục',
              disabled: !hasSelection,
              rightIcon: const Icon(Icons.arrow_forward),
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
