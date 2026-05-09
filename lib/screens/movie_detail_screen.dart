import 'package:flutter/material.dart';
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

/*
 * Màn hình MovieDetailScreen:
 * Hiển thị chi tiết bộ phim dựa trên dữ liệu thật từ MoviePublicDto.
 * Toàn bộ phần rạp chiếu (Cinemas) và lịch chiếu (Showtimes) được giả lập nội bộ hoàn toàn bằng dữ liệu Mock,
 * giúp giao diện hoạt động độc lập mượt mà trước khi hệ thống Backend tích hợp xong các đầu API rạp chiếu.
 */
class MovieDetailScreen extends StatefulWidget {
  final MoviePublicDto movie;
  final String heroTag;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.heroTag,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

/*
 * Trạng thái của MovieDetailScreen:
 * Quản lý trạng thái hiển thị giao diện chi tiết phim.
 * Chứa dữ liệu rạp chiếu và lịch chiếu giả lập cục bộ để phục vụ cho luồng chọn ghế.
 * Sử dụng hiệu ứng trễ (delayed) khi tải rạp chiếu để giả lập trải nghiệm tải dữ liệu mạng thật.
 */
class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final List<String> _dateLabels = const ['Hôm nay', 'Ngày mai'];

  final List<Showtime> _mockShowtimes = const [
    Showtime(
      id: 'show-1',
      time: '10:10',
      screen: 'Phòng 01',
      price: '120.000đ',
      availability: 'Còn nhiều chỗ',
      format: '2D',
      language: 'Phụ đề',
      dateLabel: 'Hôm nay',
    ),
    Showtime(
      id: 'show-2',
      time: '13:40',
      screen: 'Phòng 03',
      price: '150.000đ',
      availability: 'Sắp hết chỗ',
      format: 'IMAX',
      language: 'Lồng tiếng',
      dateLabel: 'Hôm nay',
    ),
    Showtime(
      id: 'show-3',
      time: '18:20',
      screen: 'Phòng 05',
      price: '170.000đ',
      availability: 'Đặt nhanh',
      format: '4DX',
      language: 'Phụ đề',
      dateLabel: 'Ngày mai',
    ),
    Showtime(
      id: 'show-4',
      time: '20:45',
      screen: 'Phòng 02',
      price: '190.000đ',
      availability: 'Giờ vàng',
      format: 'Premium',
      language: 'Phụ đề',
      dateLabel: 'Ngày mai',
    ),
  ];

  final List<Map<String, dynamic>> _mockCinemasRaw = const [
    {
      'id': 'beta-sai-gon-center',
      'name': 'Beta Two Sài Gòn Center',
      'address': '65 Lê Lợi, Quận 1, TP.HCM',
      'status': 'Đang mở cửa',
    },
    {
      'id': 'beta-east-hub',
      'name': 'Beta Two East Hub',
      'address': '12 Nguyễn Thị Minh Khai, Quận 3, TP.HCM',
      'status': 'Đang mở cửa',
    }
  ];

  bool _loadingCinemas = true;
  List<Cinema> _cinemas = const <Cinema>[];
  int _selectedDateIndex = 0;
  Showtime? _selectedShowtime;
  Cinema? _selectedCinema;

  @override
  void initState() {
    super.initState();
    _selectedShowtime = _showtimesFor(_dateLabels.first).firstOrNull;
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    setState(() {
      _loadingCinemas = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));

    final parsedCinemas = _mockCinemasRaw
        .map((data) => Cinema.fromJson(data))
        .toList();

    if (!mounted) return;
    setState(() {
      _cinemas = parsedCinemas;
      _selectedCinema = parsedCinemas.firstOrNull;
      _loadingCinemas = false;
    });
  }

  List<Showtime> _showtimesFor(String dateLabel) {
    final items = _mockShowtimes
        .where((showtime) => showtime.dateLabel == dateLabel)
        .toList(growable: false);
    return items.isEmpty ? _mockShowtimes : items;
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
                              movie.description ?? 'Đang cập nhật nội dung...',
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

    if (_cinemas.isEmpty) {
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

/*
 * Component _MovieOverview:
 * Hiển thị tóm tắt thông tin phim bao gồm Poster, Tiêu đề, Badge Trạng thái, các thông số Meta phụ và tên Đạo diễn.
 */
class _MovieOverview extends StatelessWidget {
  final MoviePublicDto movie;
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
                if (movie.status != null && movie.status!.isNotEmpty)
                  AppBadge(
                    label: movie.status!,
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
                  movie.genre ?? 'N/A',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (movie.director != null && movie.director!.isNotEmpty) ...[
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * Component _DateSelector:
 * Khối ngang hiển thị danh sách các ngày chiếu phim hỗ trợ người dùng chuyển đổi nhanh.
 */
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

/*
 * Component _StickyCta:
 * Thanh điều hướng đính kèm ở dưới cùng màn hình hiển thị tóm lược thông tin suất chiếu đã chọn và nút chọn ghế.
 */
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