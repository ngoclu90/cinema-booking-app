import 'package:flutter/material.dart';
import '../api/services/cinema_api.dart';
import '../api/services/movie_api.dart';
import '../api/services/voucher_api.dart';
import '../components/cinema/index.dart';
import '../components/movie/index.dart';
import '../components/ui/index.dart';
import '../components/voucher/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/news_item.dart';
import '../models/voucher.dart';

/*
 * Màn hình HomeScreen:
 * Trang chủ chính của ứng dụng quản lý việc gọi song song các API từ hệ thống (Phim nổi bật, Phim đang chiếu, Phim sắp chiếu, Rạp, Ưu đãi, Tin tức).
 * Tích hợp cơ chế kéo để làm mới (Pull-to-refresh) và giữ lại trạng thái màn hình (AutomaticKeepAliveClientMixin).
 */
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

/*
 * Trạng thái của HomeScreen:
 * Xử lý gọi bất đồng bộ dữ liệu thông qua Future.wait để tối ưu hóa thời gian tải trang.
 * Quản lý các trạng thái hiển thị giao diện động bao gồm Đang tải (Loading), Lỗi kết nối (Error) và Trống dữ liệu (Empty).
 */
class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final MovieApi _movieApi = const MovieApi();
  final CinemaApi _cinemaApi = const CinemaApi();
  final VoucherApi _voucherApi = const VoucherApi();

  bool _loading = true;
  Object? _error;
  List<MoviePublicDto> _featured = const <MoviePublicDto>[];
  List<MoviePublicDto> _nowPlaying = const <MoviePublicDto>[];
  List<MoviePublicDto> _comingSoon = const <MoviePublicDto>[];
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
        _movieApi.getFeaturedMovies(),
        _movieApi.getNowPlayingMovies(),
        _movieApi.getComingSoonMovies(),
        _cinemaApi.getCinemas(),
        _voucherApi.getVouchers(),
        _voucherApi.getNews(),
      ]);

      if (!mounted) return;
      setState(() {
        _featured = responses[0].data as List<MoviePublicDto>;
        _nowPlaying = responses[1].data as List<MoviePublicDto>;
        _comingSoon = responses[2].data as List<MoviePublicDto>;
        _cinemas = responses[3].data as List<Cinema>;
        _vouchers = responses[4].data as List<Voucher>;
        _news = responses[5].data as List<NewsItem>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
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
        _featured.isNotEmpty ||
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

    final heroMovie = _featured.isNotEmpty
        ? _featured.first
        : _nowPlaying.first;

    return Column(
      key: const ValueKey('home-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroMovieCard(
          movie: heroMovie,
          heroTag: 'home-hero-${heroMovie.id}',
          onPressed: () =>
              widget.onMovieTap(heroMovie, 'home-hero-${heroMovie.id}'),
          onBookPressed: () =>
              widget.onMovieTap(heroMovie, 'home-hero-${heroMovie.id}'),
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

/*
 * Component _QuickActions:
 * Hiển thị một hàng ngang chứa 3 nút truy cập nhanh: Phim, Voucher, Vé đã mua.
 */
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

/*
 * Component _QuickAction:
 * Ô lựa chọn đơn lẻ nằm trong hàng ngang QuickActions với hiệu ứng hover và bo góc đồng bộ.
 */
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

/*
 * Component _HorizontalMovies:
 * Danh sách hiển thị danh sách phim theo chiều ngang (đang chiếu hoặc sắp chiếu) có hỗ trợ scroll kéo thả mượt mà.
 */
class _HorizontalMovies extends StatelessWidget {
  final List<MoviePublicDto> movies;
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
            child: MovieCard(
              movie: movie,
              heroTag: tag,
              onPressed: () => onMovieTap(movie, tag),
            ),
          );
        },
      ),
    );
  }
}