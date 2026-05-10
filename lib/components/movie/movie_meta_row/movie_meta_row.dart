import 'package:flutter/material.dart';
import '../../../design_system/tokens/index.dart';
import '../../../models/movie.dart';

/*
 * Component MovieMetaRow:
 * Hiển thị một hàng ngang chứa các thông số cơ bản của phim (thời lượng, định dạng, ngôn ngữ).
 * Tự động điều chỉnh khoảng cách (spacing) dựa trên chế độ hiển thị thu gọn (compact).
 */
class MovieMetaRow extends StatelessWidget {
  final MoviePublicDto movie;
  final bool compact;

  const MovieMetaRow({
    super.key,
    required this.movie,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_MetaItem>[
      _MetaItem(Icons.schedule, movie.durationFormatted),
      _MetaItem(Icons.videocam_outlined, movie.format ?? '2D'),
      _MetaItem(Icons.subtitles_outlined, movie.language ?? 'N/A'),
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

/*
 * Lớp bổ trợ _MetaItem:
 * Định nghĩa cấu trúc dữ liệu cho từng mục thông số gồm một biểu tượng icon và nội dung nhãn chữ đi kèm.
 */
class _MetaItem {
  final IconData icon;
  final String label;

  const _MetaItem(this.icon, this.label);
}