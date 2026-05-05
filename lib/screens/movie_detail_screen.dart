import 'package:flutter/material.dart';

import '../api/services/cinema_api.dart';
import '../components/cinema/index.dart';
import '../components/movie/index.dart';
import '../components/ui/index.dart';
import '../design_system/tokens/index.dart';
import '../layouts/app_shell/index.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/showtime.dart';
import '../utils/app_notifier.dart';
import 'seat_selection_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final String heroTag;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.heroTag,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final CinemaApi _cinemaApi = const CinemaApi();
  final List<String> _dateLabels = const ['Hôm nay', 'Ngày mai'];

  bool _loadingCinemas = true;
  Object? _cinemaError;
  List<Cinema> _cinemas = const <Cinema>[];
  int _selectedDateIndex = 0;
  Showtime? _selectedShowtime;
  Cinema? _selectedCinema;

  @override
  void initState() {
    super.initState();
    _selectedShowtime =
        _showtimesFor(_dateLabels.first).firstOrNull ??
        widget.movie.showtimes.firstOrNull;
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    setState(() {
      _loadingCinemas = true;
      _cinemaError = null;
    });

    try {
      final response = await _cinemaApi.getCinemas();
      if (!mounted) return;
      setState(() {
        _cinemas = response.data;
        _selectedCinema = response.data.firstOrNull;
        _loadingCinemas = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cinemaError = error;
        _loadingCinemas = false;
      });
    }
  }

  List<Showtime> _showtimesFor(String dateLabel) {
    final items = widget.movie.showtimes
        .where((showtime) => showtime.dateLabel == dateLabel)
        .toList(growable: false);
    return items.isEmpty ? widget.movie.showtimes : items;
  }

  void _selectDate(int index) {
    final showtimes = _showtimesFor(_dateLabels[index]);
    setState(() {
      _selectedDateIndex = index;
      _selectedShowtime = showtimes.firstOrNull;
    });
  }

  void _openSeatSelection() {
    final showtime = _selectedShowtime;
    final cinema = _selectedCinema;

    if (showtime == null || cinema == null) {
      AppNotifier.warning(
        context,
        title: 'Chưa chọn suất chiếu',
        description: 'Hãy chọn rạp và suất chiếu trước khi chọn ghế.',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeatSelectionScreen(
          movie: widget.movie,
          showtime: showtime,
          cinema: cinema,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Chi tiết phim',
              subtitle: movie.status,
              leading: AppHeaderIconButton(
                icon: Icons.arrow_back,
                label: 'Quay lại',
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                AppHeaderIconButton(
                  icon: Icons.notifications_outlined,
                  label: 'Thông báo',
                  onPressed: () => AppNotifier.info(
                    context,
                    title: 'Thông báo',
                    description: 'Bạn sẽ nhận cập nhật khi phim có suất mới.',
                  ),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.brandPrimary,
                backgroundColor: AppColors.bgSurface,
                onRefresh: _loadCinemas,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          112,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MovieOverview(
                              movie: movie,
                              heroTag: widget.heroTag,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            Text(
                              'Nội dung phim',
                              style: AppTypography.subtitle.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              movie.description,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              title: 'Xem trailer',
                              variant: AppButtonVariant.secondary,
                              leftIcon: const Icon(Icons.play_arrow),
                              onPressed: () => AppNotifier.info(
                                context,
                                title: 'Trailer',
                                description:
                                    'Trailer sẽ được mở khi dữ liệu video sẵn sàng.',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            const SectionHeader(
                              title: 'Chọn ngày',
                              subtitle: 'Suất chiếu được nhóm theo ngày.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _DateSelector(
                              labels: _dateLabels,
                              selectedIndex: _selectedDateIndex,
                              onChanged: _selectDate,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            const SectionHeader(
                              title: 'Rạp và suất chiếu',
                              subtitle: 'Chọn rạp, sau đó chọn giờ chiếu.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildCinemaShowtimes(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _StickyCta(
        selectedShowtime: _selectedShowtime,
        selectedCinema: _selectedCinema,
        onPressed: _openSeatSelection,
      ),
    );
  }

  Widget _buildCinemaShowtimes() {
    if (_loadingCinemas) {
      return const AppSkeletonList(itemCount: 3);
    }

    if (_cinemaError != null) {
      return AppErrorState(
        title: 'Không tải được rạp',
        message: 'Hãy thử lại để lấy danh sách rạp và suất chiếu.',
        onRetry: _loadCinemas,
      );
    }

    if (_cinemas.isEmpty || widget.movie.showtimes.isEmpty) {
      return const AppEmptyState(
        title: 'Chưa có suất chiếu',
        message: 'Phim này hiện chưa mở bán vé tại rạp.',
      );
    }

    final showtimes = _showtimesFor(_dateLabels[_selectedDateIndex]);
    return Column(
      children: _cinemas
          .map(
            (cinema) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CinemaCard(
                cinema: cinema,
                showtimes: showtimes,
                selectedShowtime: _selectedCinema?.id == cinema.id
                    ? _selectedShowtime
                    : null,
                onShowtimeSelected: (showtime) {
                  setState(() {
                    _selectedCinema = cinema;
                    _selectedShowtime = showtime;
                  });
                },
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MovieOverview extends StatelessWidget {
  final Movie movie;
  final String heroTag;

  const _MovieOverview({required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
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
                  label: movie.detailLabel.isEmpty
                      ? movie.status
                      : movie.detailLabel,
                  backgroundColor: AppColors.brandPrimarySoft,
                  foregroundColor: AppColors.textPrimary,
                  borderColor: AppColors.brandPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  movie.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                MovieMetaRow(movie: movie, compact: true),
                const SizedBox(height: AppSpacing.md),
                Text(
                  movie.genre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Đạo diễn: ${movie.director}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _DateSelector({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        final selected = selectedIndex == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == labels.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => onChanged(index),
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
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionStrong.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StickyCta extends StatelessWidget {
  final Showtime? selectedShowtime;
  final Cinema? selectedCinema;
  final VoidCallback onPressed;

  const _StickyCta({
    required this.selectedShowtime,
    required this.selectedCinema,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ready = selectedShowtime != null && selectedCinema != null;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ready
                    ? '${selectedShowtime!.time} · ${selectedCinema!.name}'
                    : 'Chọn suất chiếu',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.captionStrong.copyWith(
                  color: ready ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 150,
              child: AppButton(
                title: 'Chọn ghế',
                disabled: !ready,
                rightIcon: const Icon(Icons.arrow_forward),
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
