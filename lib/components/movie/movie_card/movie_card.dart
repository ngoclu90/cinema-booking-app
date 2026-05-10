import 'package:flutter/material.dart';
import '../../../design_system/tokens/index.dart';
import '../../../models/movie.dart';
import '../../ui/index.dart';

enum MovieCardLayout { grid, horizontal }

/*
 * Component MovieCard:
 * Hiển thị thẻ thông tin phim theo hai dạng bố cục Grid (dọc) hoặc Horizontal (ngang).
 * Đồng bộ hóa dữ liệu trực tiếp từ MoviePublicDto nhận từ API Backend.
 */
class MovieCard extends StatelessWidget {
  final MoviePublicDto movie;
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
      return _buildHorizontalLayout();
    }
    return _buildGridLayout();
  }

  Widget _buildHorizontalLayout() {
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
          Expanded(
            child: _MovieSummary(movie: movie),
          ),
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

  Widget _buildGridLayout() {
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

/*
 * Component MoviePoster:
 * Cắt bo góc và cố định tỷ lệ khung hình 2:3 chuẩn cho poster phim.
 * Cho phép truyền height thủ công nếu giao diện cha yêu cầu kích thước cố định.
 */
class MoviePoster extends StatelessWidget {
  final MoviePublicDto movie;
  final double? height;

  const MoviePoster({
    super.key,
    required this.movie,
    this.height,
  });

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

/*
 * Component _PosterImage:
 * Nhận diện nguồn ảnh poster để hiển thị (từ local assets hoặc link mạng).
 * Tự động hiển thị khung xương skeleton khi đang tải hoặc chuyển hướng sang fallback UI khi gặp lỗi.
 */
class _PosterImage extends StatelessWidget {
  final MoviePublicDto movie;

  const _PosterImage({required this.movie});

  @override
  Widget build(BuildContext context) {
    final url = movie.posterUrl;

    if (url == null || url.isEmpty) {
      return _PosterFallback(movie: movie);
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _PosterFallback(movie: movie),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const AppSkeletonBox(height: double.infinity);
      },
      errorBuilder: (_, _, _) => _PosterFallback(movie: movie),
    );
  }
}

/*
 * Component _PosterFallback:
 * Giao diện thay thế dự phòng khi hình ảnh từ API trống hoặc bị lỗi mạng.
 * Tạo background gradient dựa trên thuộc tính màu sắc động của bộ phim.
 */
class _PosterFallback extends StatelessWidget {
  final MoviePublicDto movie;

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
                  movie.accentColor.withAlpha(184),
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

/*
 * Component _MovieSummary:
 * Khối văn bản hiển thị tiêu đề, thể loại, thời lượng và nhãn trạng thái của phim.
 */
class _MovieSummary extends StatelessWidget {
  final MoviePublicDto movie;
  final bool compact;

  const _MovieSummary({
    required this.movie,
    this.compact = false,
  });

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
          movie.genre ?? 'N/A',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            AppBadge(
              label: movie.durationFormatted,
              icon: const Icon(Icons.schedule),
              backgroundColor: AppColors.bgSurface2,
            ),
            if (movie.status != null && movie.status!.isNotEmpty)
              AppBadge(
                label: movie.status!,
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