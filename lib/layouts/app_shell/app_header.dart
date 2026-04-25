import 'package:flutter/material.dart';

import '../../design_system/tokens/index.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgApp,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: action,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const AppHeaderIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: AppColors.bgSurface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: const BorderSide(color: AppColors.borderDefault),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}
