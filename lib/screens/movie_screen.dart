import 'package:flutter/material.dart';
import '../api/services/movie_api.dart';
import '../components/movie/index.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/movie.dart';

enum _MovieFilter { nowPlaying, comingSoon, popular }

/*
 * Màn hình MovieScreen:
 * Quản lý danh sách toàn bộ phim được lấy từ hệ thống thông qua MovieApi.
 * Hỗ trợ các tính năng tìm kiếm động theo từ khóa, lọc phim theo trạng thái
 * (Đang chiếu, Sắp chiếu, Phổ biến) và hiển thị dưới dạng lưới Grid mượt mà.
 */
class MovieScreen extends StatefulWidget {
  final void Function(MoviePublicDto movie, String heroTag) onMovieTap;

  const MovieScreen({super.key, required this.onMovieTap});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

/*
 * Trạng thái của MovieScreen:
 * Xử lý các thao tác tương tác dữ liệu như kích hoạt thanh tìm kiếm, chuyển đổi bộ lọc Tab,
 * và thực hiện tính toán bộ lọc cục bộ (Local Filtering) trên tập dữ liệu phim tải về để tối ưu hiệu năng.
 */
class _MovieScreenState extends State<MovieScreen>
    with AutomaticKeepAliveClientMixin<MovieScreen> {
  final MovieApi _movieApi = const MovieApi();
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
      final response = await _movieApi.getAllMovies();
      if (!mounted) return;
      setState(() {
        _allMovies = response.data;
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
      _MovieFilter.popular => _allMovies.toList()
        ..sort(
              (a, b) => (b.releaseDate ?? DateTime(0))
              .compareTo(a.releaseDate ?? DateTime(0)),
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
      subtitle: 'Tìm kiếm, lọc và chọn suất chiếu',
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
              childAspectRatio: 0.53,
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

/*
 * Component _FilterTabs:
 * Thanh điều hướng chứa 3 tab trạng thái lọc chính của màn hình danh sách phim.
 */
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
          label: 'Mới nhất',
          selected: selected == _MovieFilter.popular,
          onPressed: () => onChanged(_MovieFilter.popular),
        ),
      ],
    );
  }
}

/*
 * Component _FilterTab:
 * Widget nút bấm đơn giản cấu hình trạng thái bật/tắt (selected) trực quan với màu sắc thương hiệu.
 */
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