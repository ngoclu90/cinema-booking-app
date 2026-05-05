import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../../../models/movie.dart';
import '../../ui/index.dart';

enum MovieCardLayout { grid, horizontal }

class MovieCard extends StatelessWidget {
  final Movie movie;
  final String heroTag;
  final MovieCardLayout layout;
  final VoidCallback onPressed;

  const MovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    this.layout = MovieCardLayout.grid,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (layout == MovieCardLayout.horizontal) {
      return AppCard(
        pressable: true,
        onPressed: onPressed,
        padding: AppCardPadding.sm,
        child: Row(
          children: [
            SizedBox(
              width: 82,
              child: Hero(
                tag: heroTag,
                child: MoviePoster(movie: movie),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _MovieSummary(movie: movie)),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      );
    }

    return AppCard(
      pressable: true,
      onPressed: onPressed,
      padding: AppCardPadding.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: heroTag,
            child: MoviePoster(movie: movie),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: _MovieSummary(movie: movie, compact: true),
          ),
        ],
      ),
    );
  }
}

class MoviePoster extends StatelessWidget {
  final Movie movie;
  final double? height;

  const MoviePoster({super.key, required this.movie, this.height});

  @override
  Widget build(BuildContext context) {
    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: _PosterImage(movie: movie),
      ),
    );

    if (height == null) return poster;
    return SizedBox(height: height, child: poster);
  }
}

class _PosterImage extends StatelessWidget {
  final Movie movie;

  const _PosterImage({required this.movie});

  @override
  Widget build(BuildContext context) {
    if (movie.posterUrl.isEmpty) {
      return _PosterFallback(movie: movie);
    }

    if (movie.posterUrl.startsWith('assets/')) {
      return Image.asset(
        movie.posterUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _PosterFallback(movie: movie),
      );
    }

    return Image.network(
      movie.posterUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const AppSkeletonBox(height: double.infinity);
      },
      errorBuilder: (_, _, _) => _PosterFallback(movie: movie),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  final Movie movie;

  const _PosterFallback({required this.movie});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgSurface2,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  movie.accent.withAlpha(184),
                  AppColors.bgSurface,
                  AppColors.bgApp,
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_cinema_mark.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    movie.title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieSummary extends StatelessWidget {
  final Movie movie;
  final bool compact;

  const _MovieSummary({required this.movie, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyStrong.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          movie.genre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            AppBadge(
              label: movie.duration,
              icon: const Icon(Icons.schedule),
              backgroundColor: AppColors.bgSurface2,
            ),
            AppBadge(
              label: movie.detailLabel.isEmpty
                  ? movie.status
                  : movie.detailLabel,
              backgroundColor: AppColors.brandPrimarySoft,
              foregroundColor: AppColors.textPrimary,
              borderColor: AppColors.brandPrimary,
            ),
          ],
        ),
      ],
    );
  }
}
