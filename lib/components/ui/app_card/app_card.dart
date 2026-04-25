import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardPadding padding;
  final bool bordered;
  final bool pressable;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppCardPadding.md,
    this.bordered = true,
    this.pressable = false,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: _paddingValue,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: bordered
            ? Border.all(color: AppColors.borderDefault)
            : Border.all(color: Colors.transparent),
      ),
      child: child,
    );

    if (!pressable) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: content,
      ),
    );
  }

  EdgeInsets get _paddingValue {
    switch (padding) {
      case AppCardPadding.none:
        return EdgeInsets.zero;
      case AppCardPadding.sm:
        return const EdgeInsets.all(AppSpacing.sm);
      case AppCardPadding.md:
        return const EdgeInsets.all(AppSpacing.md);
      case AppCardPadding.lg:
        return const EdgeInsets.all(AppSpacing.lg);
    }
  }
}

enum AppCardPadding { none, sm, md, lg }
