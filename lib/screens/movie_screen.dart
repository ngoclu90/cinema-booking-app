import 'package:flutter/material.dart';
import '../data/services/movie_service.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/movie.dart';

enum _MovieFilter { nowPlaying, comingSoon }

class MovieScreen extends StatefulWidget {
  final void Function(MoviePublicDto movie, String heroTag) onMovieTap;

  const MovieScreen({super.key, required this.onMovieTap});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen>
    with AutomaticKeepAliveClientMixin<MovieScreen> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  Object? _error;
  String _query = '';
  _MovieFilter _filter = _MovieFilter.nowPlaying;
  List<MoviePublicDto> _allMovies = const <MoviePublicDto>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _movieService.getAllMovie();
      if (!mounted) return;
      setState(() {
        _allMovies = response?.data ?? const <MoviePublicDto>[];
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

  List<MoviePublicDto> get _filteredMovies {
    Iterable<MoviePublicDto> source = switch (_filter) {
      _MovieFilter.nowPlaying => _allMovies.where(
            (movie) =>
        movie.status == 'Đang chiếu' ||
            movie.status?.toUpperCase() == 'NOW_SHOWING',
      ),
      _MovieFilter.comingSoon => _allMovies.where(
            (movie) =>
        movie.status == 'Sắp chiếu' ||
            movie.status?.toUpperCase() == 'COMING_SOON',
      ),
    };

    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isNotEmpty) {
      source = source.where(
            (movie) =>
        movie.title.toLowerCase().contains(normalizedQuery) ||
            (movie.genre?.toLowerCase().contains(normalizedQuery) ?? false),
      );
    }

    return source.toList(growable: false);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = _MovieFilter.nowPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScreenContainer(
      title: 'Phim',
      subtitle: 'Lựa chọn phim thỏa thích theo sở thích của bạn',
      onRefresh: _load,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Column(
        key: ValueKey('movies-loading'),
        children: [
          AppSkeletonBox(height: 48),
          SizedBox(height: AppSpacing.md),
          AppSkeletonList(itemCount: 6),
        ],
      );
    }

    if (_error != null) {
      return AppErrorState(
        key: const ValueKey('movies-error'),
        title: 'Không tải được danh sách phim',
        message: 'Hãy thử lại để lấy phim đang chiếu và sắp chiếu.',
        onRetry: _load,
      );
    }

    if (_allMovies.isEmpty) {
      return AppEmptyState(
        key: const ValueKey('movies-empty'),
        title: 'Chưa có phim',
        message: 'Danh sách phim sẽ xuất hiện khi dữ liệu sẵn sàng.',
        actionLabel: 'Tải lại',
        onAction: _load,
      );
    }

    final movies = _filteredMovies;

    return Column(
      key: const ValueKey('movies-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInput(
          controller: _searchController,
          placeholder: 'Tìm phim, thể loại...',
          leftIcon: const Icon(Icons.search),
          rightIcon: _query.isEmpty
              ? null
              : IconButton(
            tooltip: 'Xóa tìm kiếm',
            onPressed: _clearSearch,
            icon: const Icon(Icons.close),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpacing.md),
        _FilterTabs(
          selected: _filter,
          onChanged: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${movies.length} phim',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        if (movies.isEmpty)
          AppEmptyState(
            title: 'Không tìm thấy phim',
            message: 'Thử đổi từ khóa hoặc chọn bộ lọc khác.',
            actionLabel: 'Xóa bộ lọc',
            onAction: _clearSearch,
          )
        else
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.54,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final tag = 'movies-${movie.id}';
              return MovieCard(
                movie: movie,
                heroTag: tag,
                onPressed: () => widget.onMovieTap(movie, tag),
              );
            },
          ),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _MovieFilter selected;
  final ValueChanged<_MovieFilter> onChanged;

  const _FilterTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterTab(
          label: 'Đang chiếu',
          selected: selected == _MovieFilter.nowPlaying,
          onPressed: () => onChanged(_MovieFilter.nowPlaying),
        ),
        const SizedBox(width: AppSpacing.md),
        _FilterTab(
          label: 'Sắp chiếu',
          selected: selected == _MovieFilter.comingSoon,
          onPressed: () => onChanged(_MovieFilter.comingSoon),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: selected
                ? AppColors.brandPrimary
                : AppColors.bgSurface2,
            side: BorderSide(
              color: selected
                  ? AppColors.brandPrimary
                  : AppColors.borderDefault,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.captionStrong.copyWith(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final MoviePublicDto movie;
  final String heroTag;
  final VoidCallback onPressed;

  const MovieCard({
    super.key,
    required this.movie,
    required this.heroTag,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isNowShowing = movie.status == 'Đang chiếu' || movie.status?.toUpperCase() == 'NOW_SHOWING';
    final isComingSoon = movie.status == 'Sắp chiếu' || movie.status?.toUpperCase() == 'COMING_SOON';

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
            height: 38,
            child: Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  movie.durationFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
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
    if (isNowShowing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF1E27),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: const Color(0xFFFF5252), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1E27).withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Text(
          'ĐANG CHIẾU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: const Color(0xFFFF1E27), width: 1.5),
        ),
        child: const Text(
          'SẮP CHIẾU',
          style: TextStyle(
            color: Color(0xFFFF1E27),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
  }

  Widget _buildPoster() {
    final url = movie.posterUrl ?? '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    return Image.asset(
      url.isNotEmpty ? url : 'assets/images/placeholder.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.bgSurface3,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 28,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}