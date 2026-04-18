import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class ProfileItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final String? trailingLabel;
  final String? badgeLabel;
  final VoidCallback? onTap;

  const ProfileItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon = Icons.circle_outlined,
    this.trailingLabel,
    this.badgeLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlphaPercent(
                  context.isDarkMode ? 0.10 : 0.03,
                ),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlphaPercent(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  leadingIcon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlphaPercent(0.70),
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlphaPercent(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    badgeLabel!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              else if (trailingLabel != null)
                Text(
                  trailingLabel!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlphaPercent(0.7),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlphaPercent(0.42),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
