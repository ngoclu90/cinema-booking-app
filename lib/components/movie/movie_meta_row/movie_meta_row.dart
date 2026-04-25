import 'package:flutter/material.dart';

import '../../../design_system/tokens/index.dart';
import '../../../models/movie.dart';

class MovieMetaRow extends StatelessWidget {
  final Movie movie;
  final bool compact;

  const MovieMetaRow({super.key, required this.movie, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final items = <_MetaItem>[
      _MetaItem(Icons.schedule, movie.duration),
      _MetaItem(Icons.star_border, movie.rating.toStringAsFixed(1)),
      _MetaItem(Icons.subtitles_outlined, movie.language),
    ];

    return Wrap(
      spacing: compact ? AppSpacing.sm : AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionStrong.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MetaItem {
  final IconData icon;
  final String label;

  const _MetaItem(this.icon, this.label);
}
