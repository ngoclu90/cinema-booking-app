import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool reversed;
  final Widget? leading;

  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.reversed = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = reversed
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onPressed,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            gradient: reversed
                ? null
                : const LinearGradient(
                    colors: [AppTheme.brandRed, AppTheme.brandRedDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: reversed ? AppTheme.surfaceLayer(context, level: 1) : null,
            border: reversed
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlphaPercent(0.08),
                  )
                : null,
            boxShadow: reversed
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.brandRed.withAlphaPercent(0.26),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
