import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../../ui/index.dart';

class VoucherCard extends StatelessWidget {
  final String title;
  final String description;
  final String metaLabel;
  final String category;
  final String? code;
  final String actionLabel;
  final VoidCallback? onPressed;

  const VoucherCard({
    super.key,
    required this.title,
    required this.description,
    required this.metaLabel,
    required this.category,
    this.code,
    this.actionLabel = 'Dùng ngay',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 112,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.bgSurface2,
              border: Border(
                bottom: BorderSide(color: AppColors.borderDefault),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandPrimary.withAlpha(184),
                          AppColors.bgSurface2,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: AppBadge(
                    label: category,
                    backgroundColor: AppColors.bgApp,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
                const Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.textPrimary,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        code == null ? metaLabel : '$metaLabel · $code',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionStrong.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onPressed,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: Text(actionLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
