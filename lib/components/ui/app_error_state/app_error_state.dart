import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../app_button/app_button.dart';
import '../app_card/app_card.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.stateError,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              title: 'Thử lại',
              variant: AppButtonVariant.secondary,
              fullWidth: false,
              leftIcon: const Icon(Icons.refresh),
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
