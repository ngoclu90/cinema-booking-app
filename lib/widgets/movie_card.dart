import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/movie.dart';
import '../theme/design_tokens.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final String heroTag;
  final VoidCallback onTap;
  final bool compact;

  const MovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            compact ? AppRadius.large : AppRadius.hero,
          ),
          child: Container(
            width: compact ? 228 : double.infinity,
            height: compact ? 248 : 236,
            margin: compact
                ? const EdgeInsets.only(right: AppSpacing.md)
                : const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                compact ? AppRadius.large : AppRadius.hero,
              ),
              gradient: LinearGradient(
                colors: [
                  movie.accent.withAlphaPercent(0.96),
                  Color.lerp(movie.accent, Colors.black, 0.58)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: movie.accent.withAlphaPercent(0.26),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -8,
                  child: Opacity(
                    opacity: 0.14,
                    child: Image.asset(
                      'assets/images/logo_cinema_mark.png',
                      width: compact ? 116 : 138,
                    ),
                  ),
                ),
                Positioned(
                  left: -42,
                  bottom: -62,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlphaPercent(0.06),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlphaPercent(0.16),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            movie.detailLabel.toUpperCase(),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white, fontSize: 11),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlphaPercent(0.18),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.star,
                                size: 11,
                                color: Color(0xFFFFD166),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                movie.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      movie.title,
                      maxLines: compact ? 2 : 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? Theme.of(context).textTheme.titleLarge
                                  : Theme.of(context).textTheme.headlineMedium)
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: compact ? 22 : 26,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      movie.headline,
                      maxLines: compact ? 2 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlphaPercent(0.78),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.tags
                          .take(compact ? 2 : 3)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlphaPercent(0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _MetaItem(
                            icon: FontAwesomeIcons.clock,
                            label: movie.duration,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _MetaItem(
                            icon: FontAwesomeIcons.film,
                            label: compact
                                ? (movie.formats.isNotEmpty
                                      ? movie.formats.first
                                      : movie.status)
                                : movie.status,
                          ),
                        ),
                      ],
                    ),
                    if (!compact) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        movie.bookingHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlphaPercent(0.84),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final FaIconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 12, color: Colors.white.withAlphaPercent(0.82)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
