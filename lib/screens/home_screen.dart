import 'package:flutter/material.dart';
import '../api/services/cinema_api.dart';
import '../api/services/voucher_api.dart';
import '../components/movie/movie_card/movie_card.dart';
import '../data/services/movie_service.dart';
import '../components/cinema/index.dart';
import '../components/ui/index.dart';
import '../components/voucher/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/movie_card.dart';
import '../models/news_item.dart';
import '../models/voucher.dart';
import '../api/payload/api_response.dart';
import '../mocks/mock_home_movies.dart';
import '../utils/image_helper.dart'; // Đã thêm import

class HomeScreen extends StatefulWidget {
  final void Function(MoviePublicDto movie, String heroTag) onMovieTap;
  final VoidCallback? onBrowseRequested;
  final VoidCallback? onVoucherRequested;
  final VoidCallback? onTicketsRequested;

  const HomeScreen({
    super.key,
    required this.onMovieTap,
    this.onBrowseRequested,
    this.onVoucherRequested,
    this.onTicketsRequested,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final MovieService _movieService = MovieService();
  final CinemaApi _cinemaApi = CinemaApi();
  final VoucherApi _voucherApi = VoucherApi();

  bool _loading = true;
  Object? _error;

  List<MovieCardDto> _nowPlaying = const <MovieCardDto>[];
  List<MovieCardDto> _comingSoon = const <MovieCardDto>[];
  List<Cinema> _cinemas = const <Cinema>[];
  List<Voucher> _vouchers = const <Voucher>[];
  List<NewsItem> _news = const <NewsItem>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        _movieService.getMoviesByStatus(),
        _cinemaApi.getCinemas(),
        _voucherApi.getVouchers(),
        _voucherApi.getNews(),
      ]);

      if (!mounted) return;

      final movieStatusRes = responses[0] as ApiResponse<List<MovieCardDto>>?;
      final cinemasRes = responses[1] as ApiResponse<List<Cinema>>;
      final vouchersRes = responses[2] as ApiResponse<List<Voucher>>;
      final newsRes = responses[3] as ApiResponse<List<NewsItem>>;

      final List<MovieCardDto> allMovies = (movieStatusRes != null && movieStatusRes.data != null && movieStatusRes.data!.isNotEmpty)
          ? movieStatusRes.data!
          : getMockHomeMovies();

      setState(() {
        _nowPlaying = allMovies.where((m) => m.status == 'NOW_SHOWING' || m.status == 'Đang chiếu').toList();
        _comingSoon = allMovies.where((m) => m.status == 'COMING_SOON' || m.status == 'Sắp chiếu').toList();
        _cinemas = cinemasRes.data ?? const <Cinema>[];
        _vouchers = vouchersRes.data ?? const <Voucher>[];
        _news = newsRes.data ?? const <NewsItem>[];
        _loading = false;
      });
    } catch (error) {
      print('Home screen load error: $error');
      if (!mounted) return;

      final mockMovies = getMockHomeMovies();
      setState(() {
        _nowPlaying = mockMovies.where((m) => m.status == 'NOW_SHOWING' || m.status == 'Đang chiếu').toList();
        _comingSoon = mockMovies.where((m) => m.status == 'COMING_SOON' || m.status == 'Sắp chiếu').toList();
        _cinemas = const <Cinema>[];
        _vouchers = const <Voucher>[];
        _news = const <NewsItem>[];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScreenContainer(
      title: 'Trang chủ',
      subtitle: 'Phim hot, suất gần và ưu đãi hôm nay',
      onRefresh: _load,
      actions: [
        AppHeaderIconButton(
          icon: Icons.search,
          label: 'Tìm kiếm',
          onPressed: widget.onBrowseRequested,
        ),
        const AppHeaderIconButton(
          icon: Icons.notifications_outlined,
          label: 'Thông báo',
        ),
      ],
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Column(
        key: ValueKey('home-loading'),
        children: [
          AppSkeletonBox(height: 220),
          SizedBox(height: AppSpacing.md),
          AppSkeletonList(itemCount: 4),
        ],
      );
    }

    if (_error != null) {
      return AppErrorState(
        key: const ValueKey('home-error'),
        title: 'Không tải được trang chủ',
        message: 'Hãy thử lại để lấy phim, voucher và cụm rạp gần bạn.',
        onRetry: _load,
      );
    }

    final hasContent =
        _nowPlaying.isNotEmpty ||
            _comingSoon.isNotEmpty ||
            _vouchers.isNotEmpty ||
            _cinemas.isNotEmpty;

    if (!hasContent) {
      return AppEmptyState(
        key: const ValueKey('home-empty'),
        title: 'Chưa có nội dung',
        message: 'Phim, voucher và rạp sẽ xuất hiện khi dữ liệu sẵn sàng.',
        actionLabel: 'Tải lại',
        onAction: _load,
      );
    }

    final heroMovie = _nowPlaying.isNotEmpty ? _nowPlaying.first : _comingSoon.first;

    return Column(
      key: const ValueKey('home-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroMovieCard(
          movie: heroMovie,
          heroTag: 'home-hero-${heroMovie.id}',
          onPressed: () => widget.onMovieTap(heroMovie.toPublicDto(), 'home-hero-${heroMovie.id}'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _QuickActions(
          onMovies: widget.onBrowseRequested,
          onVouchers: widget.onVoucherRequested,
          onTickets: widget.onTicketsRequested,
        ),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(
          title: 'Đang chiếu',
          subtitle: 'Chọn phim và vào bước đặt vé nhanh.',
          actionLabel: 'Tất cả',
          onAction: widget.onBrowseRequested,
        ),
        const SizedBox(height: AppSpacing.md),
        _HorizontalMovies(
          movies: _nowPlaying,
          tagPrefix: 'home-now',
          onMovieTap: widget.onMovieTap,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeader(
          title: 'Sắp chiếu',
          subtitle: 'Những phim chuẩn bị mở bán trong tuần tới.',
        ),
        const SizedBox(height: AppSpacing.md),
        _HorizontalMovies(
          movies: _comingSoon,
          tagPrefix: 'home-coming',
          onMovieTap: widget.onMovieTap,
        ),
        const SizedBox(height: AppSpacing.xxl),
        SectionHeader(
          title: 'Voucher hot',
          subtitle: 'Ưu đãi đặt vé và combo bắp nước.',
          actionLabel: 'Xem thêm',
          onAction: widget.onVoucherRequested,
        ),
        const SizedBox(height: AppSpacing.md),
        if (_vouchers.isEmpty && _news.isEmpty)
          const AppEmptyState(
            title: 'Chưa có voucher',
            message: 'Ưu đãi mới sẽ được cập nhật tại đây.',
          )
        else
          VoucherCard(
            title: _vouchers.isNotEmpty
                ? _vouchers.first.title
                : _news.first.title,
            description: _vouchers.isNotEmpty
                ? _vouchers.first.description
                : _news.first.description,
            metaLabel: _vouchers.isNotEmpty
                ? _vouchers.first.expiryLabel
                : _news.first.dateLabel,
            category: _vouchers.isNotEmpty
                ? _vouchers.first.category
                : _news.first.category,
            code: _vouchers.isNotEmpty ? _vouchers.first.code : null,
            onPressed: widget.onVoucherRequested,
          ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeader(
          title: 'Rạp gần bạn',
          subtitle: 'Ưu tiên cụm rạp dễ đi và còn nhiều suất.',
        ),
        const SizedBox(height: AppSpacing.md),
        if (_cinemas.isEmpty)
          const AppEmptyState(
            title: 'Chưa có rạp',
            message: 'Danh sách cụm rạp sẽ xuất hiện khi dữ liệu sẵn sàng.',
          )
        else
          Column(
            children: _cinemas
                .take(2)
                .map(
                  (cinema) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: CinemaCard(cinema: cinema),
              ),
            )
                .toList(growable: false),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback? onMovies;
  final VoidCallback? onVouchers;
  final VoidCallback? onTickets;

  const _QuickActions({this.onMovies, this.onVouchers, this.onTickets});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.local_movies_outlined,
          label: 'Phim',
          onTap: onMovies,
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickAction(
          icon: Icons.confirmation_number_outlined,
          label: 'Voucher',
          onTap: onVouchers,
        ),
        const SizedBox(width: AppSpacing.sm),
        _QuickAction(
          icon: Icons.event_seat_outlined,
          label: 'Vé',
          onTap: onTickets,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        pressable: true,
        onPressed: onTap,
        padding: AppCardPadding.md,
        child: Column(
          children: [
            Icon(icon, color: AppColors.brandPrimary, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.captionStrong.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalMovies extends StatelessWidget {
  final List<MovieCardDto> movies;
  final String tagPrefix;
  final void Function(MoviePublicDto movie, String heroTag) onMovieTap;

  const _HorizontalMovies({
    required this.movies,
    required this.tagPrefix,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const AppEmptyState(
        title: 'Chưa có phim',
        message: 'Danh sách phim sẽ được cập nhật khi có dữ liệu.',
      );
    }

    return SizedBox(
      height: 282,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final movie = movies[index];
          final tag = '$tagPrefix-${movie.id}';
          return SizedBox(
            width: 156,
            child: HomeMovieCard(
              movie: movie,
              heroTag: tag,
              onPressed: () => onMovieTap(movie.toPublicDto(), tag),
            ),
          );
        },
      ),
    );
  }
}

class _HeroMovieCard extends StatelessWidget {
  final MovieCardDto movie;
  final String heroTag;
  final VoidCallback onPressed;

  const _HeroMovieCard({
    required this.movie,
    required this.heroTag,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isNowShowing = movie.status == 'NOW_SHOWING' || movie.status == 'Đang chiếu';

    return AppCard(
      padding: AppCardPadding.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            height: 180,
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.network(
                  ImageHelper.getCorrectImageUrl(movie.posterUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.bgSurface3,
                    child: const Icon(Icons.movie_filter_outlined, color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBadge(
                  label: isNowShowing ? 'ĐANG CHIẾU' : 'SẮP CHIẾU',
                  backgroundColor: AppColors.brandPrimarySoft,
                  foregroundColor: AppColors.brandPrimary,
                  borderColor: AppColors.brandPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Hành trình sử thi tiếp theo đầy kịch tính.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow(Icons.access_time_outlined, movie.durationFormatted),
                const SizedBox(height: AppSpacing.xs),
                _buildInfoRow(Icons.video_camera_back_outlined, 'IMAX 2D'),
                const SizedBox(height: AppSpacing.xs),
                _buildInfoRow(Icons.subtitles_outlined, 'Tiếng Anh (Phụ đề Việt)'),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: AppButton(
                    title: 'Đặt vé ngay',
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class HomeMovieCard extends StatelessWidget {
  final MovieCardDto movie;
  final String heroTag;
  final VoidCallback onPressed;

  const HomeMovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isNowShowing = movie.status == 'NOW_SHOWING' || movie.status == 'Đang chiếu';
    final isComingSoon = movie.status == 'COMING_SOON' || movie.status == 'Sắp chiếu';

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: double.infinity,
                color: AppColors.bgSurface2,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: heroTag,
                        child: _buildPoster(),
                      ),
                    ),
                    if (isNowShowing || isComingSoon)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: _buildBadge(isNowShowing),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 42,
            child: Text(
              movie.title.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.3,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  movie.durationFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isNowShowing) {
    final badgeColor = isNowShowing ? const Color(0xFFFF1E27) : const Color(0xFF1A1A1A);
    final borderColor = isNowShowing ? const Color(0xFFFF5252) : const Color(0xFFFF1E27);
    final textColor = isNowShowing ? Colors.white : const Color(0xFFFF1E27);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isNowShowing
            ? [
          BoxShadow(
            color: const Color(0xFFFF1E27).withOpacity(0.55),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: Text(
        isNowShowing ? 'ĐANG CHIẾU' : 'SẮP CHIẾU',
        style: TextStyle(
          color: textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildPoster() {
    final url = ImageHelper.getCorrectImageUrl(movie.posterUrl);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.bgSurface3,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}