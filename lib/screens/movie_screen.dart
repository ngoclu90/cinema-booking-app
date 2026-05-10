import 'dart:async';
import 'package:flutter/material.dart';
import '../data/services/movie_service.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/movie.dart';
import '../utils/image_helper.dart';

enum _MovieFilter { nowPlaying, comingSoon, popular }

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
  bool _loadingMore = false;
  Object? _error;

  int _currentPage = 1;
  final int _perPage = 10;
  bool _hasMore = true;
  List<MoviePublicDto> _movies = [];

  String _query = '';
  _MovieFilter _filter = _MovieFilter.nowPlaying;
  bool _showFilters = false;
  String? _selectedGenre;
  Timer? _searchDebounce;

  final List<Map<String, String>> _genres = [
    {'value': 'ACTION', 'label': 'Hành động'},
    {'value': 'COMEDY', 'label': 'Hài kịch'},
    {'value': 'HORROR', 'label': 'Kinh dị'},
    {'value': 'SCI_FI', 'label': 'Viễn tưởng'},
    {'value': 'ROMANCE', 'label': 'Lãng mạn'},
    {'value': 'DRAMA', 'label': 'Chính kịch'},
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  String? get _apiStatusParam {
    return switch (_filter) {
      _MovieFilter.nowPlaying => 'NOW_SHOWING',
      _MovieFilter.comingSoon => 'COMING_SOON',
      _MovieFilter.popular => null,
    };
  }

  Future<void> _loadFirstPage() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _currentPage = 1;
      _hasMore = true;
      _movies = [];
    });

    try {
      final response = await _movieService.getAllMovie(
        page: _currentPage,
        perPage: _perPage,
        title: _query.isNotEmpty ? _query : null,
        genre: _selectedGenre,
        status: _apiStatusParam,
      );

      if (!mounted) return;

      final fetchedMovies = response?.data ?? [];

      setState(() {
        _movies = fetchedMovies;
        _hasMore = fetchedMovies.length >= _perPage;

        if (_filter == _MovieFilter.popular) {
          _movies.sort((a, b) => b.id.compareTo(a.id));
        }

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

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _movieService.getAllMovie(
        page: nextPage,
        perPage: _perPage,
        title: _query.isNotEmpty ? _query : null,
        genre: _selectedGenre,
        status: _apiStatusParam,
      );

      if (!mounted) return;

      final fetchedMovies = response?.data ?? [];

      setState(() {
        _currentPage = nextPage;
        _movies.addAll(fetchedMovies);
        _hasMore = fetchedMovies.length >= _perPage;

        if (_filter == _MovieFilter.popular) {
          _movies.sort((a, b) => b.id.compareTo(a.id));
        }

        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _hasMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _loadFirstPage();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedGenre = null;
      _filter = _MovieFilter.nowPlaying;
    });
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        final triggerOffset = scrollInfo.metrics.maxScrollExtent - 200;

        if (!_loading && !_loadingMore && _hasMore && scrollInfo.metrics.pixels >= triggerOffset) {
          _loadMore();
        }
        return false;
      },
      child: ScreenContainer(
        title: 'Phim',
        subtitle: 'Tìm kiếm, lọc và chọn suất chiếu',
        onRefresh: _loadFirstPage,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildContent(),
        ),
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
        onRetry: _loadFirstPage,
      );
    }

    return Column(
      key: const ValueKey('movies-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppInput(
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
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: _showFilters ? AppColors.brandPrimary : AppColors.bgSurface2,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: _showFilters ? AppColors.brandPrimary : AppColors.borderDefault,
                  ),
                ),
                child: Icon(
                  _showFilters ? Icons.tune : Icons.tune_outlined,
                  color: _showFilters ? Colors.white : AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          child: _showFilters
              ? Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bgSurface2,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LỌC THEO THỂ LOẠI',
                      style: AppTypography.captionStrong.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (_selectedGenre != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGenre = null;
                          });
                          _loadFirstPage();
                        },
                        child: Text(
                          'Xóa lọc',
                          style: AppTypography.captionStrong.copyWith(
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: _genres.map((genre) {
                    final isSelected = _selectedGenre == genre['value'];
                    return ChoiceChip(
                      label: Text(genre['label']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGenre = selected ? genre['value'] : null;
                        });
                        _loadFirstPage();
                      },
                      selectedColor: AppColors.brandPrimary,
                      backgroundColor: AppColors.bgSurface3,
                      labelStyle: AppTypography.captionStrong.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        side: BorderSide(
                          color: isSelected ? AppColors.brandPrimary : AppColors.borderDefault,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: AppSpacing.md),
        _FilterTabs(
          selected: _filter,
          onChanged: (filter) {
            setState(() {
              _filter = filter;
            });
            _loadFirstPage();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${_movies.length} phim',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),

        if (_movies.isEmpty)
          AppEmptyState(
            title: 'Không tìm thấy phim',
            message: 'Thử đổi từ khóa hoặc chọn bộ lọc khác.',
            actionLabel: 'Xóa bộ lọc',
            onAction: _clearSearch,
          )
        else ...[
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.54,
            ),
            itemBuilder: (context, index) {
              final movie = _movies[index];
              final tag = 'movies-${movie.id}';
              return MovieCard(
                movie: movie,
                heroTag: tag,
                onPressed: () => widget.onMovieTap(movie, tag),
              );
            },
          ),

          if (_loadingMore)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                ),
              ),
            ),
        ],
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
        const SizedBox(width: AppSpacing.sm),
        _FilterTab(
          label: 'Sắp chiếu',
          selected: selected == _MovieFilter.comingSoon,
          onPressed: () => onChanged(_MovieFilter.comingSoon),
        ),
        const SizedBox(width: AppSpacing.sm),
        _FilterTab(
          label: 'Phổ biến',
          selected: selected == _MovieFilter.popular,
          onPressed: () => onChanged(_MovieFilter.popular),
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
            height: 42,
            child: Text(
              movie.title.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
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
                    fontSize: 12,
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
    if (url.startsWith('http://') || url.startsWith('https://')) {
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
          size: 32,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}