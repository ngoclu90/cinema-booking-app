import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../../../models/movie.dart';
import '../../ui/index.dart';
import '../movie_card/movie_card.dart';
import '../movie_meta_row/movie_meta_row.dart';

class HeroMovieCard extends StatelessWidget {
  final Movie movie;
  final String heroTag;
  final VoidCallback onPressed;
  final VoidCallback onBookPressed;

  const HeroMovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    required this.onPressed,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      pressable: true,
      onPressed: onPressed,
      padding: AppCardPadding.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Hero(
              tag: heroTag,
              child: MoviePoster(movie: movie),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(
                  label: movie.status,
                  backgroundColor: AppColors.brandPrimarySoft,
                  foregroundColor: AppColors.textPrimary,
                  borderColor: AppColors.brandPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  movie.headline,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                MovieMetaRow(movie: movie, compact: true),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  title: 'Đặt vé ngay',
                  size: AppButtonSize.md,
                  leftIcon: const Icon(Icons.confirmation_number_outlined),
                  onPressed: onBookPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
