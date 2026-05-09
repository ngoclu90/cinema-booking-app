import 'package:flutter/material.dart';
import '../../../design_system/tokens/index.dart';
import '../../../models/movie.dart';
import '../../ui/index.dart';
import '../movie_card/movie_card.dart';
import '../movie_meta_row/movie_meta_row.dart';

class HeroMovieCard extends StatelessWidget {
  final MoviePublicDto movie;
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
    // Kiểm tra xem phim có ở trạng thái sắp chiếu hay không
    final isComingSoon = movie.status?.toUpperCase() == 'COMING_SOON' || movie.status == 'Sắp chiếu';

    // Đổi nhãn nút dựa trên trạng thái phim (Tránh việc phim sắp chiếu nhưng nút vẫn để "Đặt vé")
    final actionText = isComingSoon ? 'Xem chi tiết' : 'Đặt vé ngay';

    // Thay đổi biểu tượng icon cho phù hợp với từng ngữ cảnh hành động
    final actionIcon = isComingSoon ? Icons.arrow_forward : Icons.confirmation_number_outlined;

    // Điều hướng hành động: Nếu sắp chiếu thì chuyển vào trang chi tiết, nếu đang chiếu thì đi tới đặt vé
    final actionCallback = isComingSoon ? onPressed : onBookPressed;

    return AppCard(
      pressable: true,
      onPressed: onPressed,
      padding: AppCardPadding.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster phim đi kèm hiệu ứng chuyển cảnh Hero
          SizedBox(
            width: 124,
            child: Hero(
              tag: heroTag,
              child: MoviePoster(movie: movie),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Cột thông tin chi tiết của bộ phim
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chỉ hiển thị Badge trạng thái nếu dữ liệu từ API thực tế trả về khác null
                if (movie.status != null && movie.status!.isNotEmpty)
                  AppBadge(
                    label: movie.status!,
                    // Trực quan hóa màu sắc: Phim sắp chiếu dùng màu cam, phim đang chiếu dùng màu chủ đạo (Red/Pink)
                    backgroundColor: isComingSoon
                        ? Colors.orange.withOpacity(0.1)
                        : AppColors.brandPrimarySoft,
                    foregroundColor: isComingSoon
                        ? Colors.orange.shade800
                        : AppColors.textPrimary,
                    borderColor: isComingSoon
                        ? Colors.orange
                        : AppColors.brandPrimary,
                  ),
                const SizedBox(height: AppSpacing.sm),

                // Tiêu đề phim giới hạn tối đa 2 dòng
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Thay thế 'headline' bằng 'shortDescription' từ DTO thật
                // Chỉ hiển thị widget nếu dữ liệu mô tả ngắn thực sự tồn tại để tránh khoảng trắng thừa trên UI
                if (movie.shortDescription != null && movie.shortDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      movie.shortDescription!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                // Hàng chứa meta-data phụ của phim (Thời lượng, định dạng...)
                MovieMetaRow(movie: movie, compact: true),
                const SizedBox(height: AppSpacing.md),

                // Nút bấm động, tự thích ứng nhãn dán và hành động dựa theo trạng thái phim
                AppButton(
                  title: actionText,
                  size: AppButtonSize.md,
                  leftIcon: Icon(actionIcon),
                  onPressed: actionCallback,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}